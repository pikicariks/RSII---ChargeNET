using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChargeNet.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddTransactionSourceTransactionId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "SourceTransactionId",
                table: "Transactions",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SourceTransactionId",
                table: "Transactions");
        }
    }
}
