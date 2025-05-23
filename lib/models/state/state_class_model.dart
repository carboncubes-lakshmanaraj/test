class Province {
  final int? state_id;
  final String state_name;
  final int state_code;

  Province({this.state_id, required this.state_name, required this.state_code});

  // Convert a StateModel into a Map (for inserting/updating into database)
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'StateName': state_name,
      'StateCode': state_code,
    };
    if (state_id != null) {
      map['StateID'] = state_id;
    }
    return map;
  }

  // Create a StateModel from a Map (from database query result)
  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      state_id: map['StateID'],
      state_name: map['StateName'],
      state_code: map['StateCode'],
    );
  }

  @override
  String toString() {
    return 'StatesProvinces(stateID: $state_id, stateName: $state_name, stateCode: $state_code)';
  }
}
