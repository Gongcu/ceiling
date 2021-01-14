class SavedStock {
  String enterprise;
  String ticker;
  SavedStock(this.enterprise, this.ticker);

  factory SavedStock.fromXlsx(List<dynamic> row) {
    return SavedStock(row[0], row[1].toString());
  }
}
