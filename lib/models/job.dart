class Job {
  final int? id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String requirements;
  final String salary;

  Job({
    this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.requirements,
    required this.salary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'requirements': requirements,
      'salary': salary,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      company: map['company'],
      location: map['location'],
      description: map['description'],
      requirements: map['requirements'],
      salary: map['salary'],
    );
  }
}