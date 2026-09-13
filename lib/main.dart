import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera initialization error: $e');
  }

  runApp(const KneeOAScreeningApp());
}

// ===============================================================
// APP
// ===============================================================

class KneeOAScreeningApp extends StatelessWidget {
  const KneeOAScreeningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Knee OA Screening',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const DashboardScreen(),
    );
  }
}

// ===============================================================
// DASHBOARD SCREEN
// ===============================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knee OA Screening')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Knee OA Screening',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'AI-assisted early knee osteoarthritis risk screening',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital, size: 40, color: Colors.blue),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Health Centre',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Screening Dashboard',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Screening Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Screenings',
                          '128',
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'High Risk',
                          '18',
                          Icons.warning,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Moderate Risk',
                          '42',
                          Icons.info,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Low Risk',
                          '68',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  );
                }

                if (constraints.maxWidth >= 600) {
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(
                        'Total Screenings',
                        '128',
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'High Risk',
                        '18',
                        Icons.warning,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'Moderate Risk',
                        '42',
                        Icons.info,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Low Risk',
                        '68',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildStatCard(
                      'Total Screenings',
                      '128',
                      Icons.people,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'High Risk',
                      '18',
                      Icons.warning,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Moderate Risk',
                      '42',
                      Icons.info,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Low Risk',
                      '68',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  'Start New Screening',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Recent Patients',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            _buildPatientCard(
              'Patient 001',
              'Age 54 • Female',
              'High Risk',
              Colors.red,
            ),

            const SizedBox(height: 12),

            _buildPatientCard(
              'Patient 002',
              'Age 47 • Male',
              'Moderate Risk',
              Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildPatientCard(
              'Patient 003',
              'Age 61 • Female',
              'Low Risk',
              Colors.green,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildPatientCard(
    String name,
    String details,
    String risk,
    Color riskColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              risk,
              style: TextStyle(
                color: riskColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// PATIENT REGISTRATION
// ===============================================================

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController ageController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screening')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Registration',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter the patient information to begin screening.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Full Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter patient name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Age',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter patient age',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: const InputDecoration(
                    hintText: 'Select gender',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ClinicalAssessmentScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// CLINICAL ASSESSMENT
// ===============================================================

class ClinicalAssessmentScreen extends StatefulWidget {
  const ClinicalAssessmentScreen({super.key});

  @override
  State<ClinicalAssessmentScreen> createState() =>
      _ClinicalAssessmentScreenState();
}

class _ClinicalAssessmentScreenState extends State<ClinicalAssessmentScreen> {
  double painLevel = 0;

  String? affectedKnee;
  String? walkingDifficulty;
  String? previousInjury;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinical & Risk Assessment',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Collect patient symptoms before movement analysis.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Pain Level (0-10)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Rate the patient\'s current knee pain.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${painLevel.round()} / 10',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: painLevel,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: painLevel.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            painLevel = value;
                          });
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('No Pain'), Text('Severe Pain')],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Affected Knee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _buildOption(
                  'Right Knee',
                  'Right',
                  affectedKnee,
                  Icons.directions_walk,
                ),

                _buildOption(
                  'Left Knee',
                  'Left',
                  affectedKnee,
                  Icons.directions_walk,
                ),

                _buildOption(
                  'Both Knees',
                  'Both',
                  affectedKnee,
                  Icons.accessibility_new,
                ),

                const SizedBox(height: 30),

                const Text(
                  'Difficulty Walking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _buildWalkingOption('None'),
                _buildWalkingOption('Mild'),
                _buildWalkingOption('Moderate'),
                _buildWalkingOption('Severe'),

                const SizedBox(height: 30),

                const Text(
                  'Previous Knee Injury',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _buildInjuryOption('Yes'),
                _buildInjuryOption('No'),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MovementAssessmentScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Continue to Movement Assessment',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    String title,
    String value,
    String? groupValue,
    IconData icon,
  ) {
    final bool selected = groupValue == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        secondary: Icon(icon, color: selected ? Colors.blue : Colors.grey),
        title: Text(title),
        activeColor: Colors.blue,
        onChanged: (value) {
          setState(() {
            affectedKnee = value;
          });
        },
      ),
    );
  }

  Widget _buildWalkingOption(String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: walkingDifficulty,
        title: Text(value),
        activeColor: Colors.orange,
        onChanged: (value) {
          setState(() {
            walkingDifficulty = value;
          });
        },
      ),
    );
  }

  Widget _buildInjuryOption(String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: previousInjury,
        title: Text(value),
        activeColor: Colors.red,
        onChanged: (value) {
          setState(() {
            previousInjury = value;
          });
        },
      ),
    );
  }
}

// ===============================================================
// MOVEMENT ASSESSMENT
// ===============================================================

class MovementAssessmentScreen extends StatefulWidget {
  const MovementAssessmentScreen({super.key});

  @override
  State<MovementAssessmentScreen> createState() =>
      _MovementAssessmentScreenState();
}

class _MovementAssessmentScreenState extends State<MovementAssessmentScreen> {
  String? walkingTest;
  String? sitToStandTest;

  double kneeFlexion = 90;

  bool videoRecorded = false;
  bool isRecording = false;
  bool isUploading = false;

  String? recordedVideoPath;

  CameraController? cameraController;
  Future<void>? cameraInitialization;

  // ===============================================================
  // API ENDPOINT
  // ===============================================================

  static const String apiUrl = 'http://10.123.133.160:8000/analyze';

  // ===============================================================
  // CAMERA INITIALIZATION
  // ===============================================================

  @override
  void initState() {
    super.initState();

    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      cameraInitialization = cameraController!.initialize();
    }
  }

  // ===============================================================
  // START RECORDING
  // ===============================================================

  Future<void> startVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera is not ready yet.')));
      return;
    }

    if (cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.startVideoRecording();

      setState(() {
        isRecording = true;
        videoRecorded = false;
        recordedVideoPath = null;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Recording started.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not start recording: $e')));
    }
  }

  // ===============================================================
  // STOP RECORDING
  // ===============================================================

  Future<void> stopVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile video = await cameraController!.stopVideoRecording();

      setState(() {
        isRecording = false;
        videoRecorded = true;
        recordedVideoPath = video.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movement video recorded successfully!')),
      );

      debugPrint('Recorded video path: ${video.path}');
    } catch (e) {
      setState(() {
        isRecording = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not stop recording: $e')));
    }
  }

  // ===============================================================
  // UPLOAD VIDEO TO AI API
  // ===============================================================

  Future<void> uploadVideoToAI() async {
    if (recordedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record a movement video first.')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      debugPrint('====================================');
      debugPrint('Uploading video to AI API...');
      debugPrint('Video: $recordedVideoPath');
      debugPrint('API: $apiUrl');
      debugPrint('====================================');

      final uri = Uri.parse(apiUrl);

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('video', recordedVideoPath!),
      );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      debugPrint('API Status Code: ${response.statusCode}');

      debugPrint('API Response: $responseBody');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(responseBody);

        setState(() {
          isUploading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIRiskScreeningScreen(result: result),
          ),
        );
      } else {
        setState(() {
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI API returned status ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('====================================');
      debugPrint('UPLOAD ERROR');
      debugPrint('$e');
      debugPrint('====================================');

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not connect to AI server.\n$e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ===============================================================
  // DISPOSE CAMERA
  // ===============================================================

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movement Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Movement Assessment',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Assess walking, functional movement and knee mobility.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 30),

                // =================================================
                // WALKING TEST
                // =================================================
                const Text(
                  'Walking Assessment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'How does the patient walk during the assessment?',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 14),

                _buildWalkingTestOption('Normal', Icons.directions_walk),

                _buildWalkingTestOption(
                  'Slightly Abnormal',
                  Icons.directions_walk,
                ),

                _buildWalkingTestOption(
                  'Clearly Abnormal',
                  Icons.warning_amber,
                ),

                const SizedBox(height: 30),

                // =================================================
                // SIT TO STAND
                // =================================================
                const Text(
                  'Sit-to-Stand Test',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Observe how easily the patient can stand from a chair.',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 14),

                _buildSitStandOption('Easy', Icons.airline_seat_recline_normal),

                _buildSitStandOption(
                  'Moderate Difficulty',
                  Icons.accessibility_new,
                ),

                _buildSitStandOption('Severe Difficulty', Icons.warning),

                const SizedBox(height: 30),

                // =================================================
                // KNEE MOBILITY
                // =================================================
                const Text(
                  'Knee Mobility',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Record the approximate knee flexion observed.',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${kneeFlexion.round()}°',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Approximate Knee Flexion',
                        style: TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 12),

                      Slider(
                        value: kneeFlexion,
                        min: 0,
                        max: 140,
                        divisions: 28,
                        label: '${kneeFlexion.round()}°',
                        onChanged: (value) {
                          setState(() {
                            kneeFlexion = value;
                          });
                        },
                      ),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('0°'), Text('140°')],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // CAMERA
                // =================================================
                const Text(
                  'Movement Video',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Use the camera to record a short walking video for movement analysis.',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                // =================================================
                // LIVE CAMERA PREVIEW
                // =================================================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: cameraController == null
                      ? const SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'No camera available',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : FutureBuilder<void>(
                          future: cameraInitialization,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (cameraController!.value.hasError) {
                                return const SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      'Camera error',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }

                              return AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              );
                            }

                            if (snapshot.hasError) {
                              return SizedBox(
                                height: 300,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Camera error:\n${snapshot.error}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // =================================================
                // RECORDING STATUS
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isRecording
                            ? Icons.fiber_manual_record
                            : videoRecorded
                            ? Icons.video_camera_back
                            : Icons.videocam_outlined,
                        size: 64,
                        color: isRecording
                            ? Colors.red
                            : videoRecorded
                            ? Colors.green
                            : Colors.blue,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        isRecording
                            ? 'Recording in progress...'
                            : videoRecorded
                            ? 'Movement video recorded'
                            : 'Camera ready',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isRecording
                            ? 'Perform the walking movement now.'
                            : videoRecorded
                            ? 'Video is ready for AI analysis.'
                            : 'Position the patient in front of the camera.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // RECORD BUTTON
                      // =================================================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isUploading
                              ? null
                              : isRecording
                              ? stopVideoRecording
                              : startVideoRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRecording
                                ? Colors.red
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(isRecording ? Icons.stop : Icons.videocam),
                          label: Text(
                            isRecording
                                ? 'Stop Recording'
                                : videoRecorded
                                ? 'Record Again'
                                : 'Start Recording',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (videoRecorded && recordedVideoPath != null) ...[
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Video saved successfully.\n\n$recordedVideoPath',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // =================================================
                // SUMMARY
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: Colors.green,
                        size: 32,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Movement Analysis',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'The recorded movement video will be uploaded to the AI server for analysis.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // AI BUTTON
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: videoRecorded && !isUploading
                        ? uploadVideoToAI
                        : null,
                    icon: isUploading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(
                      isUploading
                          ? 'Analyzing Movement...'
                          : 'Continue to AI Risk Screening',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // WALKING OPTION
  // ===============================================================

  Widget _buildWalkingTestOption(String value, IconData icon) {
    final bool selected = walkingTest == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: walkingTest,
        secondary: Icon(icon, color: selected ? Colors.blue : Colors.grey),
        title: Text(value),
        activeColor: Colors.blue,
        onChanged: (value) {
          setState(() {
            walkingTest = value;
          });
        },
      ),
    );
  }

  // ===============================================================
  // SIT TO STAND OPTION
  // ===============================================================

  Widget _buildSitStandOption(String value, IconData icon) {
    final bool selected = sitToStandTest == value;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        value: value,
        groupValue: sitToStandTest,
        secondary: Icon(icon, color: selected ? Colors.orange : Colors.grey),
        title: Text(value),
        activeColor: Colors.orange,
        onChanged: (value) {
          setState(() {
            sitToStandTest = value;
          });
        },
      ),
    );
  }
}

// ===============================================================
// AI RISK SCREENING
// ===============================================================

class AIRiskScreeningScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AIRiskScreeningScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final int riskScore = (result['risk_score'] ?? 0) as int;

    final String riskLevel = result['risk_level']?.toString() ?? 'Unknown';

    final String filename = result['filename']?.toString() ?? 'Movement video';

    Color riskColor;

    if (riskScore >= 75) {
      riskColor = Colors.red;
    } else if (riskScore >= 40) {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Risk Screening')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Movement Analysis',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Analysis completed from the recorded movement video.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 30),

                // =================================================
                // RISK SCORE
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.psychology, size: 60, color: riskColor),

                      const SizedBox(height: 16),

                      const Text(
                        'Preliminary OA Risk Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$riskScore / 100',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          riskLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // VIDEO
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.video_file,
                        size: 35,
                        color: Colors.blue,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Analyzed Video',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              filename,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'AI Analysis Results',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // =================================================
                // DYNAMIC METRICS
                // =================================================
                _buildResultCard(
                  'Walking Speed',
                  '${result['walking_speed'] ?? 'N/A'} m/s',
                  Icons.speed,
                ),

                _buildResultCard(
                  'Sit-to-Stand',
                  '${result['sit_to_stand_time'] ?? 'N/A'} sec',
                  Icons.accessibility_new,
                ),

                _buildResultCard(
                  'Knee Flexion',
                  '${result['knee_flexion'] ?? 'N/A'}°',
                  Icons.directions_walk,
                ),

                _buildResultCard(
                  'Movement Symmetry',
                  '${result['movement_symmetry'] ?? 'N/A'}%',
                  Icons.sync_alt,
                ),

                _buildResultCard(
                  'Left Knee Stability',
                  '${result['left_knee_stability'] ?? 'N/A'}%',
                  Icons.accessibility,
                ),

                _buildResultCard(
                  'Right Knee Stability',
                  '${result['right_knee_stability'] ?? 'N/A'}%',
                  Icons.accessibility,
                ),

                const SizedBox(height: 30),

                // =================================================
                // INDICATORS
                // =================================================
                const Text(
                  'Risk Indicators',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                _buildIndicators(),

                const SizedBox(height: 30),

                // =================================================
                // RECOMMENDATION
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Recommendation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Text(
                        'The AI result is a preliminary screening result. Further clinical evaluation is recommended before making any medical decision.',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // BACK BUTTON
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Movement Assessment'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // RESULT CARD
  // ===============================================================

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // INDICATORS
  // ===============================================================

  Widget _buildIndicators() {
    final dynamic indicators = result['indicators'];

    if (indicators is List && indicators.isNotEmpty) {
      return Column(
        children: indicators.map<Widget>((item) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(child: Text(item.toString())),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No specific risk indicators were returned by the AI server.',
      ),
    );
  }
}
