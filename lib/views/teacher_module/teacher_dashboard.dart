import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class TeacherDashboard extends StatelessWidget {
  final String teacherName;


  const TeacherDashboard({Key? key, required this.teacherName}) : super(key: key);

  Future<void> _uploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          String csvString = String.fromCharCodes(file.bytes!);
          List<List<dynamic>> rows = CsvToListConverter().convert(csvString);


          List<dynamic> headers = rows.first;


          List<Map<String, dynamic>> flattenedData = [];


          for (int i = 1; i < rows.length; i++) {
            Map<String, dynamic> rowData = {};
            List<dynamic> row = rows[i];

            for (int j = 0; j < headers.length; j++) {
              rowData[headers[j].toString()] = row[j];
            }

            flattenedData.add(rowData);
          }


          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('timetables')
              .where('teacherName', isEqualTo: teacherName)
              .get();

          if (querySnapshot.docs.isNotEmpty) {

            DocumentSnapshot docSnapshot = querySnapshot.docs.first;
            await docSnapshot.reference.update({
              'data': flattenedData,
              'timestamp': DateTime.now(),
            });
          } else {

            await FirebaseFirestore.instance.collection('timetables').add({
              'teacherName': teacherName,
              'data': flattenedData,
              'timestamp': DateTime.now(),
            });
          }


          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File uploaded successfully!'),
          ));
        } else {

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: File bytes are null.'),
          ));
        }
      } else {

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No file selected.'),
        ));
      }
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading file: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Welcome, $teacherName!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _uploadFile(context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Upload Timetable'),
            ),

            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => UpdateTimetablePage(teacherName: teacherName),
            //       ),
            //     );
            //   },
            //   child: Text('Update Timetable'),
            //   style: ElevatedButton.styleFrom(
            //
            //     textStyle: TextStyle(fontSize: 18),
            //   ),
            // ),
            // SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTimetablePage(teacherName: teacherName),
                  ),
                );
              },
              child: Text('View Timetable'),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateTimetablePage extends StatelessWidget {
  final String teacherName;

  UpdateTimetablePage({required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Timetable'),
      ),
      body: UpdateTimetableForm(teacherName: teacherName),
    );
  }
}

class UpdateTimetableForm extends StatefulWidget {
  final String teacherName;

  UpdateTimetableForm({required this.teacherName});

  @override
  _UpdateTimetableFormState createState() => _UpdateTimetableFormState();
}

class _UpdateTimetableFormState extends State<UpdateTimetableForm> {
  String? selectedDay;
  String? selectedHour;
  String newValue = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: selectedDay,
            hint: Text('Select a day'),
            onChanged: (value) {
              setState(() {
                selectedDay = value;
              });
            },
            items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
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
          TextFormField(
            onChanged: (value) {
              newValue = value;
            },
            decoration: InputDecoration(
              labelText: 'New Value',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedDay != null && selectedHour != null && newValue.isNotEmpty) {
                updateTimetable();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please select a day, an hour, and enter a new value.'),
                ));
              }
            },
            child: Text('Update Timetable'),
          ),
        ],
      ),
    );
  }

  void updateTimetable() {
    if (widget.teacherName.isNotEmpty && selectedDay != null && selectedHour != null && newValue.isNotEmpty) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('timetables').doc(widget.teacherName);
      docRef.get().then((DocumentSnapshot docSnapshot) {
        if (docSnapshot.exists) {
          Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            if (data.containsKey(selectedDay)) {
              Map<String, dynamic>? dayData = data[selectedDay] as Map<String, dynamic>?;

              if (dayData != null) {
                dayData[selectedHour!] = newValue;
                docRef.update({'data': data}).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Timetable updated successfully!'),
                    ),
                  );
                }).catchError((error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update timetable: $error'),
                    ),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected day data is null.'),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected day not found in timetable.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Timetable data is null.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document does not exist for teacher: ${widget.teacherName}'),
            ),
          );
        }
      }).catchError((error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error retrieving timetable: $error'),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
    }
  }



}


class ViewTimetablePage extends StatelessWidget {
  final String teacherName;

  ViewTimetablePage({required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Timetable'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('timetables').where('teacherName', isEqualTo: teacherName).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No timetables available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc['data'] as List<dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Teacher: $teacherName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _buildTableColumns(data.first.length),
                        rows: _buildTableRows(data),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Uploaded on: ${doc['timestamp'].toDate()}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<DataColumn> _buildTableColumns(int numberOfColumns) {
    return List.generate(
      numberOfColumns,
          (index) => DataColumn(
        label: index == 0 ? Text('Days') : Text('Hour $index'),
      ),
    );
  }

  List<DataRow> _buildTableRows(List<dynamic> rows) {
    return List.generate(
      rows.length,
          (index) {
        var rowMap = rows[index] as Map<dynamic, dynamic>;
        return DataRow(
          cells: List.generate(
            rowMap.length,
                (cellIndex) {
              if (cellIndex == 0) {
                var day = rowMap['ï»¿Day'];
                return DataCell(
                  Text(day != null ? day.toString() : ''),
                );
              } else {
                var cellValue = rowMap[(cellIndex).toString()];
                return DataCell(
                  Text(cellValue != null ? cellValue.toString() : ''),
                );
              }
            },
          ),
        );
      },
    );
  }
}



