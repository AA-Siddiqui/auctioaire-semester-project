import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final incrementController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? uploadedImage;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTimeRange? dateTimeRange;
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Enter item name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    labelText: 'Enter starting bid',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a starting bid';
                    }
                    double? val = double.tryParse(value);
                    if (val == null) {
                      return "Please enter a valid amount";
                    }
                    if (val <= 0) {
                      return "Please enter a positive amount";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: incrementController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    labelText: 'Enter increment amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an increment amount';
                    }
                    double? val = double.tryParse(value);
                    if (val == null) {
                      return "Please enter a valid amount";
                    }
                    if (val <= 0) {
                      return "Please enter a positive amount";
                    }
                    return null;
                  },
                ),
                // const SizedBox(height: 16),
                // TextFormField(
                //   decoration: const InputDecoration(
                //     labelText: 'Enter Category',
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter an increment amount';
                //     }
                //     double? val = double.tryParse(value);
                //     if (val == null) {
                //       return "Please enter a valid amount";
                //     }
                //     if (val <= 0) {
                //       return "Please enter a positive amount";
                //     }
                //     return null;
                //   },
                // ),

                GestureDetector(
                  onTap: () async {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(
                        days: 90,
                      )),
                    ).then((value) {
                      setState(() {
                        dateTimeRange = value;
                      });
                    });
                  },
                  child: TextField(
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Auction Duration',
                      hintText: 'Select Auction Duration',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: dateTimeRange == null
                          ? ""
                          : "${dateTimeRange!.start.month}/${dateTimeRange!.start.day}/${dateTimeRange!.start.year} - ${dateTimeRange!.end.month}/${dateTimeRange!.end.day}/${dateTimeRange!.end.year}",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: 0,
                        minute: 0,
                      ),
                    ).then((value) {
                      setState(() {
                        startTime = value;
                      });
                    });
                  },
                  child: TextField(
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      hintText: 'Select Bidding Start Time',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: startTime == null
                          ? ""
                          : "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: 0,
                        minute: 0,
                      ),
                    ).then((value) {
                      setState(() {
                        endTime = value;
                      });
                    });
                  },
                  child: TextField(
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      hintText: 'Select Bidding End Time',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: endTime == null
                          ? ""
                          : "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
                uploadedImage == null
                    ? ElevatedButton(
                        onPressed: () async {
                          isUploading = true;
                          final result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result != null &&
                              result.files.single.path != null) {
                            final file = File(result.files.single.path!);
                            final fileName = result.files.single.name;

                            try {
                              await Supabase.instance.client.storage
                                  .from('auctioaire')
                                  .upload(fileName, file);

                              setState(() {
                                uploadedImage = Supabase.instance.client.storage
                                    .from('auctioaire')
                                    .getPublicUrl(fileName);
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Image uploaded successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to upload image: $e')),
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No image selected')),
                              );
                            }
                          }
                          isUploading = false;
                        },
                        child: const Text('Upload Image'),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Image.network(
                          uploadedImage!,
                          height: 150,
                        ),
                      ),
                ElevatedButton(
                  onPressed: () async {
                    if (dateTimeRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select Date Range')),
                      );
                      return;
                    }
                    if (startTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select Starting Time')),
                      );
                      return;
                    }
                    if (endTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select Ending Time')),
                      );
                      return;
                    }
                    if (uploadedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upload an Image')),
                      );
                      return;
                    }
                    final initDate = dateTimeRange!.start;
                    final endDate = dateTimeRange!.end;
                    final startingTime = DateTime(
                      initDate.year,
                      initDate.month,
                      initDate.day,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    final endingTime = DateTime(
                      endDate.year,
                      endDate.month,
                      endDate.day,
                      endTime!.hour,
                      endTime!.minute,
                    );

                    if (formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Form submitted successfully')),
                      );

                      // make firebase request
                      FirebaseFirestore.instance.collection("auction").add({
                        "title": titleController.text,
                        "startTime": Timestamp.fromDate(startingTime),
                        "endTime": Timestamp.fromDate(endingTime),
                        "amount": double.parse(amountController.text.trim()),
                        "increment":
                            double.parse(incrementController.text.trim()),
                        "imageUrl": uploadedImage,
                      }).then((value) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: isUploading
                      ? CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
