import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'dart:async';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  FocusModePageState createState() => FocusModePageState();
}

class FocusModePageState extends State<FocusModePage> with SingleTickerProviderStateMixin {
  Task? _selectedTask;
  TimerType _currentTimerType = TimerType.work;
  TimerState _timerState = TimerState.idle;
  int _remainingSeconds = 25 * 60; // 25 minutes in seconds
  late AnimationController _animationController;
  int _completedSessions = 0;
  final TextEditingController _workDurationController = TextEditingController(text: '25');
  final TextEditingController _breakDurationController = TextEditingController(text: '5');

  // Timer durations in seconds
  int get workDuration {
    final val = int.tryParse(_workDurationController.text);
    return (val != null && val > 0) ? val * 60 : 25 * 60;
  }
  int get breakDuration {
    final val = int.tryParse(_breakDurationController.text);
    return (val != null && val > 0) ? val * 60 : 5 * 60;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _remainingSeconds = workDuration;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _workDurationController.dispose();
    _breakDurationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_timerState == TimerState.running || _selectedTask == null) return;

    setState(() {
      _timerState = TimerState.running;
    });

    _animationController.forward();

    // Timer logic
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timerState != TimerState.running) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _timerState = TimerState.paused;
    });
    _animationController.stop();
  }

  void _resetTimer() {
    setState(() {
      _timerState = TimerState.idle;
      _remainingSeconds = _currentTimerType == TimerType.work ? workDuration : breakDuration;
    });
    _animationController.reset();
  }

  void _completeSession() {
    _animationController.reverse();
    
    setState(() {
      if (_currentTimerType == TimerType.work) {
        _completedSessions++;
        _currentTimerType = TimerType.break_;
        _remainingSeconds = breakDuration;
        
        // Show break notification
        _showSessionCompleteDialog('Waktu kerja selesai! Istirahat ${breakDuration ~/ 60} menit.');
      } else {
        _currentTimerType = TimerType.work;
        _remainingSeconds = workDuration;
        
        // Show work notification
        _showSessionCompleteDialog('Istirahat selesai! Waktu kerja ${workDuration ~/ 60} menit.');
      }
      
      _timerState = TimerState.idle;
    });
  }

  void _showSessionCompleteDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer(); // Start next session automatically
            },
            child: const Text('Mulai Sesi Berikutnya'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    int totalDuration = _currentTimerType == TimerType.work ? workDuration : breakDuration;
    return 1 - (_remainingSeconds / totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final pendingTasks = taskProvider.pendingTasks;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Focus Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tingkatkan produktivitas dengan teknik Pomodoro',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Task Selection Dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonFormField<Task>(
              value: _selectedTask,
              items: pendingTasks.map((task) {
                return DropdownMenuItem<Task>(
                  value: task,
                  child: Text(
                    task.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (task) {
                setState(() {
                  _selectedTask = task;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Pilih Task untuk Fokus',
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              isExpanded: true,
            ),
          ),

          const SizedBox(height: 16),

          // Duration Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atur Durasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _workDurationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kerja (menit)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          if (_timerState == TimerState.idle && _currentTimerType == TimerType.work) {
                            setState(() {
                              _remainingSeconds = workDuration;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _breakDurationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Istirahat (menit)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          if (_timerState == TimerState.idle && _currentTimerType == TimerType.break_) {
                            setState(() {
                              _remainingSeconds = breakDuration;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selected Task Display
          if (_selectedTask != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedTask!.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedTask!.color.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.task_alt, color: _selectedTask!.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTask!.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedTask!.color,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTask!.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _selectedTask!.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Timer Display
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Type Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currentTimerType == TimerType.work 
                      ? Colors.blue[50] 
                      : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentTimerType == TimerType.work ? 'FOKUS KERJA' : 'WAKTU ISTIRAHAT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _currentTimerType == TimerType.work 
                        ? Colors.blue[700] 
                        : Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Circular Progress Arc (80% circle)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: _progress,
                          backgroundColor: Colors.grey[300]!,
                          color: _currentTimerType == TimerType.work 
                            ? Colors.blue 
                            : Colors.green,
                          strokeWidth: 10,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentTimerType == TimerType.work 
                            ? '${workDuration ~/ 60} menit fokus' 
                            : '${breakDuration ~/ 60} menit istirahat',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      label: 'Mulai',
                      onPressed: _timerState == TimerState.running ? null : _startTimer,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.pause,
                      label: 'Jeda',
                      onPressed: _timerState == TimerState.running ? _pauseTimer : null,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildControlButton(
                      icon: Icons.refresh,
                      label: 'Reset',
                      onPressed: _resetTimer,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Session Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Sesi selesai: $_completedSessions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: onPressed != null ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed != null ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Custom painter for circular progress arc (80% circle)
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw 80% circle arcs (start at 180 degrees, sweep 288 degrees for 80% of 360)
    const startAngle = -3.14; // Start at top (180 degrees in radians)
    const sweepAngle = 2.512; // 80% of 360 degrees in radians (288 degrees)

    // Draw background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum TimerType { work, break_ }

enum TimerState { idle, running, paused }