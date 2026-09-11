class Client {
  final String id;
  final String companyName;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final int activeJobs;
  final int completedJobs;
  final String notes;

  const Client({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.activeJobs,
    required this.completedJobs,
    this.notes = '',
  });
}
