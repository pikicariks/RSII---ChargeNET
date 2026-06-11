import 'package:chargenet_mobile/features/reservation/reservation_providers.dart';
import 'package:chargenet_mobile/features/station/station_providers.dart';
import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M3 — create reservation, track status, start charging when confirmed.
class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key, required this.stationId});

  final int stationId;

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  int? _connectorId;
  late DateTime _start;
  late DateTime _end;
  Reservation? _created;
  var _isSubmitting = false;
  var _isStarting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day, now.hour + 1);
    _end = _start.add(const Duration(hours: 2));
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;
    setState(() {
      _start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (!_end.isAfter(_start)) {
        _end = _start.add(const Duration(hours: 2));
      }
    });
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (time == null || !mounted) return;
    setState(() {
      _end = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_connectorId == null) {
      setState(() => _error = 'Select a connector');
      return;
    }
    if (!_end.isAfter(_start)) {
      setState(() => _error = 'End time must be after start time');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final reservation = await api.createReservation({
        'chargingStationId': widget.stationId,
        'connectorId': _connectorId,
        'reservationStart': _start.toUtc().toIso8601String(),
        'reservationEnd': _end.toUtc().toIso8601String(),
      });
      if (!mounted) return;
      setState(() {
        _created = reservation;
        _isSubmitting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isSubmitting = false;
      });
    }
  }

  Future<void> _refreshReservation() async {
    final id = _created?.id;
    if (id == null) return;
    ref.invalidate(reservationProvider(id));
    final updated = await ref.read(reservationProvider(id).future);
    if (mounted) setState(() => _created = updated);
  }

  Future<void> _cancelReservation() async {
    final id = _created?.id;
    if (id == null) return;
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final updated = await api.cancelReservation(id);
      if (mounted) setState(() => _created = updated);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _startCharging() async {
    final reservation = _created;
    if (reservation == null || reservation.connectorId == null) return;

    setState(() => _isStarting = true);
    try {
      final api = await ref.read(chargeNetApiProvider.future);
      final tariffs = await api.getTariffs(isActive: true);
      if (tariffs.isEmpty) {
        throw const ApiException(message: 'No active tariff available');
      }
      final session = await api.startSession(
        connectorId: reservation.connectorId!,
        tariffId: tariffs.first.id,
        reservationId: reservation.id,
      );
      if (!mounted) return;
      context.push('/charging/${session.id}');
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  String _formatDt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}.${local.month}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final station = ref.watch(stationDetailProvider(widget.stationId));
    final connectors = ref.watch(stationConnectorsProvider(widget.stationId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Reserve'),
      ),
      body: station.when(
        loading: () => const CnLoading(message: 'Loading…'),
        error: (e, _) => CnErrorView(message: e.toString()),
        data: (s) {
          if (_created != null) {
            return _ReservationStatusView(
              reservation: _created!,
              onRefresh: _refreshReservation,
              onCancel: _created!.isPending ? _cancelReservation : null,
              onStart: _created!.isConfirmed ? _startCharging : null,
              isStarting: _isStarting,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.name, style: ChargeNetTextStyles.title()),
                const SizedBox(height: ChargeNetSpacing.lg),
                connectors.when(
                  loading: () => const CnLoading(expand: false),
                  error: (e, _) => Text(e.toString()),
                  data: (list) {
                    final available =
                        list.where((c) => c.isAvailable).toList();
                    if (available.isEmpty) {
                      return Text(
                        'No available connectors at this station.',
                        style: ChargeNetTextStyles.bodySm(),
                      );
                    }
                    return DropdownButtonFormField<int>(
                      initialValue: _connectorId,
                      dropdownColor: ChargeNetColors.surface,
                      decoration: const InputDecoration(labelText: 'Connector'),
                      items: available
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                '${c.label ?? c.connectorTypeName} · ${c.powerKw.toStringAsFixed(0)} kW',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _connectorId = v),
                    );
                  },
                ),
                const SizedBox(height: ChargeNetSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Start', style: ChargeNetTextStyles.label()),
                  subtitle: Text(_formatDt(_start)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickStart,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('End', style: ChargeNetTextStyles.label()),
                  subtitle: Text(_formatDt(_end)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickEnd,
                ),
                if (_error != null) ...[
                  const SizedBox(height: ChargeNetSpacing.sm),
                  Text(
                    _error!,
                    style: ChargeNetTextStyles.caption(
                      color: ChargeNetColors.warning,
                    ),
                  ),
                ],
                const SizedBox(height: ChargeNetSpacing.lg),
                CnButton(
                  label: 'Confirm reservation',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: ChargeNetSpacing.sm),
                Text(
                  'Admin must confirm before you can start charging.',
                  textAlign: TextAlign.center,
                  style: ChargeNetTextStyles.caption(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationStatusView extends StatelessWidget {
  const _ReservationStatusView({
    required this.reservation,
    required this.onRefresh,
    this.onCancel,
    this.onStart,
    required this.isStarting,
  });

  final Reservation reservation;
  final VoidCallback onRefresh;
  final VoidCallback? onCancel;
  final VoidCallback? onStart;
  final bool isStarting;

  @override
  Widget build(BuildContext context) {
    final status = reservation.isConfirmed
        ? CnStationStatus.active
        : reservation.isPending
            ? CnStationStatus.maintenance
            : CnStationStatus.inactive;

    return Padding(
      padding: const EdgeInsets.all(ChargeNetSpacing.mobileHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CnCard(
            gradientBorder: reservation.isConfirmed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reservation.chargingStationName,
                        style: ChargeNetTextStyles.title(),
                      ),
                    ),
                    CnStatusBadge(status: status, compact: true),
                  ],
                ),
                const SizedBox(height: ChargeNetSpacing.sm),
                Text(
                  'Reservation #${reservation.id}',
                  style: ChargeNetTextStyles.bodySm(),
                ),
                if (reservation.connectorLabel != null)
                  Text(
                    reservation.connectorLabel!,
                    style: ChargeNetTextStyles.caption(),
                  ),
                const SizedBox(height: ChargeNetSpacing.md),
                Text(
                  '${_fmt(reservation.reservationStart)} → ${_fmt(reservation.reservationEnd)}',
                  style: ChargeNetTextStyles.caption(),
                ),
                if (reservation.isPending) ...[
                  const SizedBox(height: ChargeNetSpacing.md),
                  Text(
                    'Waiting for admin confirmation. Tap refresh after admin confirms in the desktop app.',
                    style: ChargeNetTextStyles.bodySm(
                      color: ChargeNetColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ChargeNetSpacing.md),
          CnButton(
            label: 'Refresh status',
            variant: CnButtonVariant.secondary,
            onPressed: onRefresh,
          ),
          if (onStart != null) ...[
            const SizedBox(height: ChargeNetSpacing.sm),
            CnButton(
              label: 'Start charging',
              icon: Icons.bolt_rounded,
              isLoading: isStarting,
              onPressed: isStarting ? null : onStart,
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: ChargeNetSpacing.sm),
            CnButton(
              label: 'Cancel reservation',
              variant: CnButtonVariant.destructive,
              onPressed: onCancel,
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}.${local.month} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
