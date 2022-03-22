import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_x_todo/controllers/task_controller.dart';
import 'package:get_x_todo/models/task.dart';
import 'package:get_x_todo/ui/widgets/button.dart';
import 'package:intl/intl.dart';

import '../theme.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titelController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(Duration(minutes: 15)))
      .toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Add Task',
                style: headingStyel,
              ),
              InputField(
                  titel: 'titel',
                  hint: 'Enter Titel here',
                  controller: _titelController),
              /******************************* */

              InputField(
                  titel: 'Note',
                  hint: 'Enter Note here',
                  controller: _noteController),
              /********************* */
              InputField(
                titel: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => getDateFromUser(),
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      titel: 'Start Time',
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () => getTimeFromUser(isStartTime: true),
                        icon: const Icon(
                          Icons.access_time_filled_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InputField(
                      titel: 'End Time',
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () => getTimeFromUser(isStartTime: false),
                        icon: const Icon(
                          Icons.access_time_filled_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                  titel: 'Remind',
                  hint: '$_selectedRemind minutes early',
                  widget: Row(
                    children: [
                      DropdownButton(
                        dropdownColor: Colors.blueGrey,
                        items: remindList
                            .map<DropdownMenuItem<String>>((int value) =>
                                DropdownMenuItem<String>(
                                  value: value.toString(),
                                  child: Text(
                                    "$value",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        iconSize: 32,
                        elevation: 4,
                        underline: Container(height: 0),
                        style: subTitelStyel,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRemind = int.parse(newValue!);
                          });
                        },
                      ),
                      SizedBox(
                        width: 6,
                      ),
                    ],
                  )),
              InputField(
                  titel: 'Repeat',
                  hint: _selectedRepeat,
                  widget: Row(
                    children: [
                      DropdownButton(
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.blueGrey,
                        items: repeatList
                            .map<DropdownMenuItem<String>>((String value) =>
                                DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        iconSize: 32,
                        elevation: 4,
                        underline: Container(height: 0),
                        style: subTitelStyel,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRepeat = newValue!;
                          });
                        },
                      ),
                      SizedBox(
                        width: 6,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(
                      label: 'Create Task',
                      onTap: () {
                        _validateDate();
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: primaryClr,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  _validateDate() {
    if (_titelController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTasksToDb();
      Get.back();
    } else if (_titelController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar('required', 'All fields are required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    } else {
      print('########SOMETHING BAD HAPPENED########');
    }
  }

  _addTasksToDb() async {
    try {
      int value = await _taskController.addTask(
          task: Task(
              title: _titelController.text,
              note: _noteController.text,
              isCompleted: 0,
              date: DateFormat.yMd().format(_selectedDate),
              startTime: _startTime,
              endTime: _endTime,
              color: _selectedColor,
              remind: _selectedRemind,
              repeat: _selectedRepeat));
      print(value);
    } catch (e) {
      print('Error!');
    }
  }

  Column _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: titelStyel,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          children: List.generate(
            3,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : orangeClr,
                  child: _selectedColor == index
                      ? Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                  radius: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2035));
    if (_pickedDate != null)
      setState(() {
        _selectedDate = _pickedDate;
      });
    else
      print('');
  }

  getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 15))),
    );
    String _formattedTime = _pickedTime!.format(context);
    if (isStartTime)
      setState(() {
        _formattedTime = _startTime;
      });
    else if (!isStartTime)
      setState(() {
        _formattedTime = _startTime;
      });
    else {
      print('time canceld or something is wrong!');
    }
  }
}
