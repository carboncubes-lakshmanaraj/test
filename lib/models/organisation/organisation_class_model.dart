class Organisation {
  final int? organisationId;
  final String organisationName;
  final String? contactPerson;
  final String addressLine1;
  final String? addressLine2;
  final int stateId;
  final String? pincode;
  final String? emailAddress;
  final String? mobileNumber;
  final String? gstNumber;
  final bool isBiller;

  Organisation({
    this.organisationId,
    required this.organisationName,
    this.contactPerson,
    required this.addressLine1,
    this.addressLine2,
    required this.stateId,
    this.pincode,
    this.emailAddress,
    this.mobileNumber,
    this.gstNumber,
    required this.isBiller,
  });

  factory Organisation.fromMap(Map<String, dynamic> map) {
    return Organisation(
      organisationId: map['OrganisationID'],
      organisationName: map['OrganisationName'],
      contactPerson: map['ContactPerson'],
      addressLine1: map['AddressLine1'],
      addressLine2: map['AddressLine2'],
      stateId: map['StateID'],
      pincode: map['Pincode'],
      emailAddress: map['EmailAddress'],
      mobileNumber: map['MobileNumber'],
      gstNumber: map['GSTNumber'],
      isBiller: map['IsBiller'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'OrganisationID': organisationId,
      'OrganisationName': organisationName,
      'ContactPerson': contactPerson,
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'StateID': stateId,
      'Pincode': pincode,
      'EmailAddress': emailAddress,
      'MobileNumber': mobileNumber,
      'GSTNumber': gstNumber,
      'IsBiller': isBiller ? 1 : 0,
    };
  }
}
