class OrganizationInfo {
  final String name;
  final String address;

  const OrganizationInfo({required this.name, required this.address});

  @override
  bool operator ==(Object other) =>
      other is OrganizationInfo &&
      other.name == name &&
      other.address == address;

  @override
  int get hashCode => Object.hash(name, address);
}
