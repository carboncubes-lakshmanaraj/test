class TaxCode {
  final int? taxCodeId;
  final String taxCode;
  final String description;
  final int isHSN;
  final int isActive;
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;
  //change done hello
  TaxCode({
    this.taxCodeId,
    required this.taxCode,
    required this.description,
    required this.isHSN,
    required this.isActive,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
  });

  Map<String, dynamic> toMap() {
    return {
      'TaxCodeID': taxCodeId,
      'TaxCode': taxCode,
      'Description': description,
      'IsHSN': isHSN,
      'IsActive': isActive,
      'CGST': cgst,
      'SGST': sgst,
      'IGST': igst,
      'Cess': cess,
    };
  }

  factory TaxCode.fromMap(Map<String, dynamic> map) {
    return TaxCode(
      taxCodeId: map['TaxCodeID'],
      taxCode: map['TaxCode'],
      description: map['Description'] ?? '',
      isHSN: map['IsHSN'],
      isActive: map['IsActive'],
      cgst: (map['CGST'] as num).toDouble(),
      sgst: (map['SGST'] as num).toDouble(),
      igst: (map['IGST'] as num).toDouble(),
      cess: (map['Cess'] as num).toDouble(),
    );
  }
}
