class Schedule {
  final String day;
  final String time;

  Schedule({required this.day, required this.time});

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      Schedule(day: json['day'], time: json['time']);
}

class Doctor {
  final int id;
  final String name;
  final String speciality;
  final String? photoPath;
  final List<Schedule> schedules;

  Doctor({
    required this.id,
    required this.name,
    required this.speciality,
    this.photoPath,
    required this.schedules,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'],
        name: json['name'],
        speciality: json['speciality'],
        photoPath: json['photo_path'],
        schedules: (json['schedules'] as List)
            .map((item) => Schedule.fromJson(item))
            .toList(),
      );
}

class Clinic {
  final int id;
  final String name;
  final List<Doctor> doctors;

  Clinic({
    required this.id,
    required this.name,
    required this.doctors,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
        id: json['id'],
        name: json['name'],
        doctors: (json['doctors'] as List)
            .map((doc) => Doctor.fromJson(doc))
            .toList(),
      );
}
