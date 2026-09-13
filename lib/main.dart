import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

List<CameraDescription> cameras = [];

const String apiBaseUrl = 'http://10.123.133.160:8000';

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
// DASHBOARD
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

            _statCard('Total Screenings', '128', Icons.people, Colors.blue),

            const SizedBox(height: 12),

            // =====================================================
            // TOTAL SCREENINGS / PATIENT DATA BUTTON
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TotalScreeningsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.people_alt_outlined, size: 26),
                label: const Text(
                  'View All Patient Data',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _statCard('High Risk', '18', Icons.warning, Colors.red),

            const SizedBox(height: 12),

            _statCard('Moderate Risk', '42', Icons.info, Colors.orange),

            const SizedBox(height: 12),

            _statCard('Low Risk', '68', Icons.check_circle, Colors.green),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Start New Screening',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // SAVED VIDEOS BUTTON
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SavedVideosScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.video_library, size: 28),
                label: const Text(
                  'Saved Videos',
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

            _patientCard(
              'Patient 001',
              'Age 54 • Female',
              'High Risk',
              Colors.red,
            ),

            const SizedBox(height: 12),

            _patientCard(
              'Patient 002',
              'Age 47 • Male',
              'Moderate Risk',
              Colors.orange,
            ),

            const SizedBox(height: 12),

            _patientCard(
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

  static Widget _statCard(
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
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _patientCard(
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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(details, style: TextStyle(color: Colors.grey[600])),
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
              style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// TOTAL SCREENINGS / PATIENT DATA
// ===============================================================

class TotalScreeningsScreen extends StatefulWidget {
  const TotalScreeningsScreen({super.key});

  @override
  State<TotalScreeningsScreen> createState() => _TotalScreeningsScreenState();
}

class _TotalScreeningsScreenState extends State<TotalScreeningsScreen> {
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/patients'));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final dynamic patientData = decoded['patients'];

          if (patientData is List) {
            setState(() {
              patients = patientData
                  .whereType<Map>()
                  .map((patient) => Map<String, dynamic>.from(patient))
                  .toList();
              isLoading = false;
            });
          } else {
            throw Exception(
              'The server response does not contain a valid patients list.',
            );
          }
        } else if (decoded is List) {
          // Also support a plain list response for compatibility.
          setState(() {
            patients = decoded
                .whereType<Map>()
                .map((patient) => Map<String, dynamic>.from(patient))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected patient data received from server.');
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load patient data.\n$e';
      });
    }
  }

  String displayValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not available';
    }
    return value.toString();
  }

  Color riskColor(String risk) {
    final value = risk.toLowerCase();
    if (value.contains('high')) return Colors.red;
    if (value.contains('moderate')) return Colors.orange;
    if (value.contains('low')) return Colors.green;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Screenings'),
        actions: [
          IconButton(
            tooltip: 'Refresh patient data',
            onPressed: isLoading ? null : fetchPatients,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: fetchPatients,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : patients.isEmpty
          ? RefreshIndicator(
              onRefresh: fetchPatients,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.people_outline, size: 70),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No patient screenings found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(child: Text('Pull down to refresh.')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchPatients,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  final risk = displayValue(patient['risk_level']);
                  final riskColour = riskColor(risk);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      leading: CircleAvatar(
                        radius: 25,
                        child: Text(
                          displayValue(patient['id']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        displayValue(patient['name']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Age ${displayValue(patient['age'])} • ${displayValue(patient['gender'])}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: riskColour.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          risk,
                          style: TextStyle(
                            color: riskColour,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      children: [
                        _dataRow('Patient ID', patient['id']),
                        _dataRow('Phone', patient['phone']),
                        _dataRow('Pain Level', patient['pain_level']),
                        _dataRow('Affected Knee', patient['affected_knee']),
                        _dataRow(
                          'Walking Difficulty',
                          patient['walking_difficulty'],
                        ),
                        _dataRow('Previous Injury', patient['previous_injury']),
                        _dataRow('Knee Mobility', patient['knee_mobility']),
                        _dataRow('Knee Flexion', patient['knee_flexion']),
                        _dataRow('Walking Speed', patient['walking_speed']),
                        _dataRow(
                          'Sit-to-Stand Time',
                          patient['sit_to_stand_time'],
                        ),
                        _dataRow(
                          'Movement Symmetry',
                          patient['movement_symmetry'],
                        ),
                        _dataRow('Risk Score', patient['risk_score']),
                        _dataRow('Risk Level', patient['risk_level']),
                        _dataRow('Video', patient['video_filename']),
                        _dataRow('Screening Date', patient['screening_date']),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _dataRow(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(displayValue(value), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// SAVED VIDEOS SCREEN
// ===============================================================

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  List<Map<String, dynamic>> videos = [];

  bool isLoading = true;
  String? errorMessage;
  String? deletingFilename;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  // =============================================================
  // LOAD VIDEOS
  // =============================================================

  Future<void> loadVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/videos'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> videoList = data['videos'] ?? [];

        setState(() {
          videos = videoList
              .map((video) => Map<String, dynamic>.from(video))
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Server returned status ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not connect to the AI server.\n$e';
      });
    }
  }

  // =============================================================
  // DELETE VIDEO
  // =============================================================

  Future<void> deleteVideo(String filename) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Video?'),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete this video?\n\n$filename',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      deletingFilename = filename;
    });

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/videos/${Uri.encodeComponent(filename)}'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            videos.removeWhere((video) => video['filename'] == filename);

            deletingFilename = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            deletingFilename = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message']?.toString() ?? 'Could not delete video.',
              ),
            ),
          );
        }
      } else {
        setState(() {
          deletingFilename = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Delete failed. Server returned ${response.statusCode}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deletingFilename = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not connect to server.\n$e')),
      );
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadVideos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 70, color: Colors.red),
              const SizedBox(height: 20),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadVideos,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadVideos,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(Icons.video_library_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Center(
              child: Text(
                'No saved videos found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(child: Text('Recorded videos will appear here.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadVideos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];

          final String filename =
              video['filename']?.toString() ?? 'Unknown video';

          final dynamic sizeValue = video['size_bytes'];

          String sizeText = '';

          if (sizeValue is num) {
            final double mb = sizeValue / (1024 * 1024);

            sizeText = '${mb.toStringAsFixed(2)} MB';
          }

          final bool isDeleting = deletingFilename == filename;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // VIDEO ICON
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.video_file,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // VIDEO INFORMATION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (sizeText.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            sizeText,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // PLAY BUTTON
                  IconButton(
                    tooltip: 'Play video',
                    onPressed: isDeleting
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VideoPlayerScreen(filename: filename),
                              ),
                            );
                          },
                    icon: const Icon(
                      Icons.play_circle_fill,
                      size: 34,
                      color: Colors.blue,
                    ),
                  ),

                  // DELETE BUTTON
                  IconButton(
                    tooltip: 'Delete video',
                    onPressed: isDeleting
                        ? null
                        : () {
                            deleteVideo(filename);
                          },
                    icon: isDeleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete, size: 28, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================================================
// VIDEO PLAYER
// ===============================================================

class VideoPlayerScreen extends StatefulWidget {
  final String filename;

  const VideoPlayerScreen({super.key, required this.filename});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;

  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  Future<void> initializeVideo() async {
    try {
      final String videoUrl =
          '$apiBaseUrl/videos/${Uri.encodeComponent(widget.filename)}';

      controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load video.\n$e';
      });
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Center(
        child: errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(errorMessage!, textAlign: TextAlign.center),
              )
            : !isInitialized
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.filename,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),

                  const SizedBox(height: 20),

                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),

                  const SizedBox(height: 15),

                  IconButton(
                    iconSize: 55,
                    onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                  ),
                ],
              ),
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
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void continueToClinicalAssessment() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the patient name.')),
      );
      return;
    }

    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age.')),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the patient gender.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicalAssessmentScreen(
          patientName: name,
          patientAge: age,
          patientGender: selectedGender!,
        ),
      ),
    );
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
                  'Enter patient information to begin screening.',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

                const SizedBox(height: 20),

                const Text(
                  'Age',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

                const SizedBox(height: 20),

                const Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: continueToClinicalAssessment,
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
  final String patientName;
  final int patientAge;
  final String patientGender;

  const ClinicalAssessmentScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
  });

  @override
  State<ClinicalAssessmentScreen> createState() =>
      _ClinicalAssessmentScreenState();
}

class _ClinicalAssessmentScreenState extends State<ClinicalAssessmentScreen> {
  double painLevel = 0;

  String? affectedKnee;
  String? walkingDifficulty;
  String? previousInjury;

  void continueToMovementAssessment() {
    if (affectedKnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the affected knee.')),
      );
      return;
    }

    if (walkingDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the walking difficulty.')),
      );
      return;
    }

    if (previousInjury == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select whether there was a previous injury.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovementAssessmentScreen(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientGender: widget.patientGender,
          painLevel: painLevel.round(),
          affectedKnee: affectedKnee!,
          walkingDifficulty: walkingDifficulty!,
          previousInjury: previousInjury!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical & Risk Assessment',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            const Text(
              'Pain Level (0-10)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            Center(
              child: Text(
                '${painLevel.round()} / 10',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Affected Knee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _radioOption(
              'Right Knee',
              'Right',
              affectedKnee,
              Icons.directions_walk,
              (value) {
                setState(() {
                  affectedKnee = value;
                });
              },
            ),

            _radioOption(
              'Left Knee',
              'Left',
              affectedKnee,
              Icons.directions_walk,
              (value) {
                setState(() {
                  affectedKnee = value;
                });
              },
            ),

            _radioOption(
              'Both Knees',
              'Both',
              affectedKnee,
              Icons.accessibility_new,
              (value) {
                setState(() {
                  affectedKnee = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Difficulty Walking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _simpleRadio('None', walkingDifficulty, (value) {
              setState(() {
                walkingDifficulty = value;
              });
            }),

            _simpleRadio('Mild', walkingDifficulty, (value) {
              setState(() {
                walkingDifficulty = value;
              });
            }),

            _simpleRadio('Moderate', walkingDifficulty, (value) {
              setState(() {
                walkingDifficulty = value;
              });
            }),

            _simpleRadio('Severe', walkingDifficulty, (value) {
              setState(() {
                walkingDifficulty = value;
              });
            }),

            const SizedBox(height: 20),

            const Text(
              'Previous Knee Injury',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _simpleRadio('Yes', previousInjury, (value) {
              setState(() {
                previousInjury = value;
              });
            }),

            _simpleRadio('No', previousInjury, (value) {
              setState(() {
                previousInjury = value;
              });
            }),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: continueToMovementAssessment,
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Continue to Movement Assessment',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption(
    String title,
    String value,
    String? groupValue,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        secondary: Icon(icon),
        title: Text(title),
        onChanged: onChanged,
      ),
    );
  }

  Widget _simpleRadio(
    String value,
    String? groupValue,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        title: Text(value),
        onChanged: onChanged,
      ),
    );
  }
}

// ===============================================================
// MOVEMENT ASSESSMENT
// ===============================================================

class MovementAssessmentScreen extends StatefulWidget {
  final String patientName;
  final int patientAge;
  final String patientGender;

  final int painLevel;
  final String affectedKnee;
  final String walkingDifficulty;
  final String previousInjury;

  const MovementAssessmentScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.painLevel,
    required this.affectedKnee,
    required this.walkingDifficulty,
    required this.previousInjury,
  });

  @override
  State<MovementAssessmentScreen> createState() =>
      _MovementAssessmentScreenState();
}

class _MovementAssessmentScreenState extends State<MovementAssessmentScreen> {
  CameraController? cameraController;
  Future<void>? cameraInitialization;

  bool isRecording = false;
  bool videoRecorded = false;
  bool isUploading = false;

  String? recordedVideoPath;

  double kneeFlexion = 90;

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

  Future<void> startVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera is not ready yet.')));
      return;
    }

    try {
      await cameraController!.startVideoRecording();

      if (!mounted) return;

      setState(() {
        isRecording = true;
        videoRecorded = false;
        recordedVideoPath = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not start recording: $e')));
    }
  }

  Future<void> stopVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile video = await cameraController!.stopVideoRecording();

      if (!mounted) return;

      setState(() {
        isRecording = false;
        videoRecorded = true;
        recordedVideoPath = video.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movement video recorded successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isRecording = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not stop recording: $e')));
    }
  }

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
      // -----------------------------------------------------------
      // STEP 1: Upload movement video for AI analysis
      // -----------------------------------------------------------
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/analyze'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('video', recordedVideoPath!),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI server returned ${response.statusCode}')),
        );
        return;
      }

      final Map<String, dynamic> result = Map<String, dynamic>.from(
        jsonDecode(responseBody),
      );

      // -----------------------------------------------------------
      // STEP 2: Read AI result values safely
      // -----------------------------------------------------------
      final dynamic riskScoreValue = result['risk_score'];
      final dynamic riskLevelValue = result['risk_level'];
      final dynamic filenameValue = result['filename'];
      final dynamic walkingSpeedValue = result['walking_speed'];
      final dynamic sitToStandValue = result['sit_to_stand_time'];
      final dynamic aiKneeFlexionValue = result['knee_flexion'];
      final dynamic movementSymmetryValue = result['movement_symmetry'];

      final double riskScore = riskScoreValue is num
          ? riskScoreValue.toDouble()
          : 0;

      final String riskLevel = riskLevelValue?.toString() ?? 'Unknown';

      final String filename = filenameValue?.toString() ?? '';

      final double walkingSpeed = walkingSpeedValue is num
          ? walkingSpeedValue.toDouble()
          : 0;

      final double sitToStandTime = sitToStandValue is num
          ? sitToStandValue.toDouble()
          : 0;

      final double aiKneeFlexion = aiKneeFlexionValue is num
          ? aiKneeFlexionValue.toDouble()
          : kneeFlexion;

      final double movementSymmetry = movementSymmetryValue is num
          ? movementSymmetryValue.toDouble()
          : 0;

      // -----------------------------------------------------------
      // STEP 3: Save the COMPLETE screening to the database
      // -----------------------------------------------------------
      // FastAPI /patients/complete currently accepts query parameters.
      final completeUri = Uri.parse('$apiBaseUrl/patients/complete').replace(
        queryParameters: {
          'name': widget.patientName,
          'age': widget.patientAge.toString(),
          'gender': widget.patientGender,
          'pain_level': widget.painLevel.toString(),
          'affected_knee': widget.affectedKnee,
          'walking_difficulty': widget.walkingDifficulty,
          'previous_injury': widget.previousInjury,
          'knee_mobility': kneeFlexion.toString(),
          'knee_flexion': aiKneeFlexion.toString(),
          'walking_speed': walkingSpeed.toString(),
          'sit_to_stand_time': sitToStandTime.toString(),
          'movement_symmetry': movementSymmetry.toString(),
          'risk_score': riskScore.toString(),
          'risk_level': riskLevel,
          'video_filename': filename,
        },
      );

      final saveResponse = await http.post(completeUri);

      if (!mounted) return;

      if (saveResponse.statusCode != 200) {
        setState(() {
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI analysis succeeded, but patient data could not be saved. '
              'Server returned ${saveResponse.statusCode}.',
            ),
          ),
        );
        return;
      }

      final dynamic saveDecoded = jsonDecode(saveResponse.body);

      if (saveDecoded is! Map<String, dynamic>) {
        setState(() {
          isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient save response was invalid.')),
        );
        return;
      }

      // Add useful information to the result shown on the AI screen.
      result['patient_id'] = saveDecoded['patient_id'];
      result['risk_score'] = riskScore;
      result['risk_level'] = riskLevel;
      result['filename'] = filename;
      result['walking_speed'] = walkingSpeed;
      result['sit_to_stand_time'] = sitToStandTime;
      result['knee_flexion'] = aiKneeFlexion;
      result['movement_symmetry'] = movementSymmetry;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Screening saved successfully. Patient ID: ${saveDecoded['patient_id']}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // -----------------------------------------------------------
      // STEP 4: Show the AI result
      // -----------------------------------------------------------
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AIRiskScreeningScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete screening.\n$e')),
      );
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movement Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Movement Assessment',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            const Text(
              'Knee Mobility',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                '${kneeFlexion.round()}°',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Slider(
              value: kneeFlexion,
              min: 0,
              max: 140,
              divisions: 28,
              onChanged: (value) {
                setState(() {
                  kneeFlexion = value;
                });
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'Movement Video',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // CAMERA
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
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio: cameraController!.value.aspectRatio,
                            child: CameraPreview(cameraController!),
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

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isUploading
                    ? null
                    : isRecording
                    ? stopVideoRecording
                    : startVideoRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecording ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(isRecording ? Icons.stop : Icons.videocam),
                label: Text(
                  isRecording
                      ? 'Stop Recording'
                      : videoRecorded
                      ? 'Record Again'
                      : 'Start Recording',
                ),
              ),
            ),

            if (videoRecorded) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Movement video recorded successfully.'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

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
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
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
    final dynamic scoreValue = result['risk_score'];

    final int riskScore = scoreValue is num
        ? scoreValue.toInt()
        : int.tryParse(scoreValue?.toString() ?? '') ?? 0;

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
        child: Column(
          children: [
            const Text(
              'AI Movement Analysis',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology, size: 60, color: riskColor),

                  const SizedBox(height: 15),

                  const Text(
                    'Preliminary OA Risk Score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                  const SizedBox(height: 10),

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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _resultCard('Analyzed Video', filename, Icons.video_file),

            _resultCard(
              'Walking Speed',
              '${result['walking_speed'] ?? 'N/A'} m/s',
              Icons.speed,
            ),

            _resultCard(
              'Sit-to-Stand',
              '${result['sit_to_stand_time'] ?? 'N/A'} sec',
              Icons.accessibility_new,
            ),

            _resultCard(
              'Knee Flexion',
              '${result['knee_flexion'] ?? 'N/A'}°',
              Icons.directions_walk,
            ),

            _resultCard(
              'Movement Symmetry',
              '${result['movement_symmetry'] ?? 'N/A'}%',
              Icons.sync_alt,
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'This is a preliminary screening result and should not be used as a medical diagnosis. Further clinical evaluation is recommended.',
                style: TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Movement Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(String title, String value, IconData icon) {
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
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
