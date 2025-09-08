import 'package:inldsevak/features/complaints/model/official.dart';


class OfficialsData {
  static final Map<String, List<Official>> _officialsByDepartment = {
    'Amunik Corporation': [
      Official(
        id: '1',
        name: 'Kaamport',
        email: 'kaamport@gmail.com',
        department: 'Amunik Corporation',
        designation: 'Investor',
        phone: '+91-798107400',
      ),
      Official(
        id: '2',
        name: 'Uday Kiran',
        email: 'puvvalaudaykiran@gmail.com',
        department: 'Amunik Corporation',
        designation: 'CEO',
        phone: '+91-798107400',
      ),
      Official(
        id: '3',
        name: 'Dhiraj Navik',
        email: 'dhiraj.amunik@gmail.com',
        department: 'Amunik Corporation',
        designation: 'Software Develpoer',
        phone: '+91-9866717428',
      ),
    ],
    'Municipal Corporation': [
      Official(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        email: 'rajesh.kumar@municipal.gov.in',
        department: 'Municipal Corporation',
        designation: 'Municipal Commissioner',
        phone: '+91-9876543210',
      ),
      Official(
        id: '2',
        name: 'Mrs. Priya Sharma',
        email: 'priya.sharma@municipal.gov.in',
        department: 'Municipal Corporation',
        designation: 'Assistant Commissioner',
        phone: '+91-9876543211',
      ),
    ],
    'Water Board': [
      Official(
        id: '3',
        name: 'Mr. Amit Singh',
        email: 'amit.singh@waterboard.gov.in',
        department: 'Water Board',
        designation: 'Chief Engineer',
        phone: '+91-9876543212',
      ),
      Official(
        id: '4',
        name: 'Ms. Sunita Patel',
        email: 'sunita.patel@waterboard.gov.in',
        department: 'Water Board',
        designation: 'Executive Engineer',
        phone: '+91-9876543213',
      ),
    ],
    'PWD': [
      Official(
        id: '5',
        name: 'Mr. Vikram Gupta',
        email: 'vikram.gupta@pwd.gov.in',
        department: 'PWD',
        designation: 'Superintending Engineer',
        phone: '+91-9876543214',
      ),
    ],
    'Electricity Board': [
      Official(
        id: '6',
        name: 'Dr. Meera Joshi',
        email: 'meera.joshi@electricity.gov.in',
        department: 'Electricity Board',
        designation: 'Chief Electrical Engineer',
        phone: '+91-9876543215',
      ),
    ],
    'Transport Department': [
      Official(
        id: '7',
        name: 'Mr. Ravi Verma',
        email: 'ravi.verma@transport.gov.in',
        department: 'Transport Department',
        designation: 'Transport Commissioner',
        phone: '+91-9876543216',
      ),
    ],
    'Health Department': [
      Official(
        id: '8',
        name: 'Dr. Kavita Reddy',
        email: 'kavita.reddy@health.gov.in',
        department: 'Health Department',
        designation: 'Chief Medical Officer',
        phone: '+91-9876543217',
      ),
    ],
  };

  static List<Official> getOfficialsByDepartment(String department) {
    return _officialsByDepartment[department] ?? [];
  }

  static List<String> getAllDepartments() {
    return _officialsByDepartment.keys.toList();
  }

  static Official? getOfficialById(String id) {
    for (final officials in _officialsByDepartment.values) {
      for (final official in officials) {
        if (official.id == id) return official;
      }
    }
    return null;
  }
}
