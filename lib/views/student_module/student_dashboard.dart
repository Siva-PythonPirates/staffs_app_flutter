import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSearchPage extends StatefulWidget {
  @override
  _StudentSearchPageState createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  String? selectedDay;
  String? selectedHour;
  List<String> availableTeachers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for Available Teachers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedDay,
              hint: Text('Select a day'),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                });
              },
              items: ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedHour,
              hint: Text('Select an hour'),
              onChanged: (value) {
                setState(() {
                  selectedHour = value;
                });
              },
              items: ['Hour 1', 'Hour 2', 'Hour 3', 'Hour 4', 'Hour 5', 'Hour 6', 'Hour 7', 'Hour 8']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedDay != null && selectedHour != null) {
                  searchAvailableTeachers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please select a day and an hour.'),
                  ));
                }
              },
              child: Text('Search'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Text(
                'Available Teachers :',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 20),
            if (availableTeachers.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: availableTeachers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          availableTeachers[index].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              ),
          ],
        ),
      ),
    );
  }

  void searchAvailableTeachers() async {
    print('Searching available teachers...');

    print('Selected day: $selectedDay');
    print('Selected hour: $selectedHour');

    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('timetables').get();

    List<String> teachers = [];

    querySnapshot.docs.forEach((doc) {
      print('Processing document: ${doc.id}');
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('data')) {
        List<dynamic>? timetables = data['data'] as List<dynamic>?;

        if (timetables != null) {
          print('Processing timetable for selected day: $selectedDay');
          timetables.forEach((timetable) {
            print('Keys in timetable: ${timetable.keys}');
            print('Processing timetable: $timetable');
            print('Timetable data type: ${timetable.runtimeType}');
            if(timetable['ï»¿Day']==selectedDay){
              print(selectedDay);
              print(timetable[selectedHour!.split(' ')[1]]);
              print(timetable['$selectedHour']);
              if(timetable[selectedHour!.split(' ')[1]]=="" || timetable[selectedHour!.split(' ')[1]]==null){
                print(
                    'Teacher is free during $selectedDay, Hour $selectedHour');
                teachers.add(data['teacherName']);
              }
            }
          });
        }
      }
    });

    if (teachers.isEmpty) {
      teachers.add('No teachers available during selected time.');
    }

    setState(() {
      availableTeachers = teachers;
    });
  }





}
