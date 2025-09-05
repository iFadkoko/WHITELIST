import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'week'; // 'week', 'month', 'year'
  
  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (weekday >= 1 && weekday <= 7) ? days[weekday] : '';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  // Calculate weekly stats: returns Map<DateTime, double>
  Map<DateTime, double> _calculateWeeklyStats(TaskProvider provider) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final Map<DateTime, double> stats = {};
    
    for (int i = 0; i < 7; i++) {
      final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i);
      final tasks = provider.allTasks.where((task) =>
        task.date.year == day.year &&
        task.date.month == day.month &&
        task.date.day == day.day
      ).toList();
      
      final completedCount = tasks.where((task) => task.isCompleted).length;
      final totalCount = tasks.length;
      stats[day] = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;
    }
    return stats;
  }

  // Calculate monthly stats: returns Map<DateTime, double>
  Map<DateTime, double> _calculateMonthlyStats(TaskProvider provider) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final Map<DateTime, double> stats = {};
    
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      final tasks = provider.allTasks.where((task) =>
        task.date.year == day.year &&
        task.date.month == day.month &&
        task.date.day == day.day
      ).toList();
      
      final completedCount = tasks.where((task) => task.isCompleted).length;
      final totalCount = tasks.length;
      stats[day] = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;
    }
    return stats;
  }

  // Calculate yearly stats: returns Map<int, double> (month number to percentage)
  Map<int, double> _calculateYearlyStats(TaskProvider provider) {
    final now = DateTime.now();
    final Map<int, double> stats = {};
    
    for (int month = 1; month <= 12; month++) {
      final tasks = provider.allTasks.where((task) =>
        task.date.year == now.year &&
        task.date.month == month
      ).toList();
      
      final completedCount = tasks.where((task) => task.isCompleted).length;
      final totalCount = tasks.length;
      stats[month] = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;
    }
    return stats;
  }

  Widget _buildWeeklyBarChart(Map<DateTime, double> weeklyData) {
    final sortedDates = weeklyData.keys.toList()..sort();
    if (sortedDates.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No weekly data available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    final bars = sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final productivity = weeklyData[date] ?? 0.0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: productivity,
            color: _getColorForValue(productivity),
            width: 20,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedDates.length) {
                    final date = sortedDates[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getDayName(date.weekday),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          maxY: 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dateIndex = group.x;
                if (dateIndex >= 0 && dateIndex < sortedDates.length) {
                  final date = sortedDates[dateIndex];
                  return BarTooltipItem(
                    '${_getDayName(date.weekday)}\n${rod.toY.toStringAsFixed(1)}%',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return BarTooltipItem('', const TextStyle());
              },
              // Parameter tooltipBgColor mungkin tidak tersedia di versi fl_chart Anda
              // tooltipBgColor: Colors.blue[800],
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyLineChart(Map<DateTime, double> monthlyData) {
    final sortedDates = monthlyData.keys.toList()..sort();
    if (sortedDates.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No monthly data available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    final spots = sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final productivity = monthlyData[date] ?? 0.0;
      return FlSpot(index.toDouble(), productivity);
    }).toList();
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < sortedDates.length) {
                    final date = sortedDates[index];
                    return LineTooltipItem(
                      '${date.day}/${date.month}\n${spot.y.toStringAsFixed(1)}%',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return LineTooltipItem('', const TextStyle());
                }).toList();
              },
              // Parameter tooltipBgColor mungkin tidak tersedia di versi fl_chart Anda
              // tooltipBgColor: Colors.blue[800],
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedDates.length && index % 5 == 0) {
                    final date = sortedDates[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          minX: 0,
          maxX: sortedDates.length > 0 ? sortedDates.length.toDouble() - 1 : 0,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[700]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyBarChart(Map<int, double> yearlyData) {
    if (yearlyData.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No yearly data available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    final bars = yearlyData.entries.map((entry) {
      final month = entry.key;
      final productivity = entry.value;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: productivity,
            color: _getColorForValue(productivity),
            width: 16,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();
    
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final month = value.toInt();
                  if (month >= 1 && month <= 12 && month % 2 == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getMonthName(month),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          maxY: 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = group.x;
                if (month >= 1 && month <= 12) {
                  return BarTooltipItem(
                    '${_getMonthName(month)}\n${rod.toY.toStringAsFixed(1)}%',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return BarTooltipItem('', const TextStyle());
              },
              // Parameter tooltipBgColor mungkin tidak tersedia di versi fl_chart Anda
              // tooltipBgColor: Colors.blue[800],
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 80) return Colors.green[400]!;
    if (value >= 60) return Colors.blue[400]!;
    if (value >= 40) return Colors.orange[400]!;
    return Colors.red[400]!;
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('Week', 'week'),
          _buildPeriodButton('Month', 'month'),
          _buildPeriodButton('Year', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[500]! : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(TaskProvider provider) {
    final int totalTasks = provider.allTasks.length;
    final int completedTasks = provider.allTasks.where((task) => task.isCompleted).length;
    final double completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Tasks', totalTasks.toString(), Icons.task_alt),
          _buildSummaryItem('Completed', completedTasks.toString(), Icons.check_circle),
          _buildSummaryItem('Completion', '${completionRate.toStringAsFixed(1)}%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[500], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[500]!),
            ),
          );
        }

        final weeklyData = _calculateWeeklyStats(taskProvider);
        final monthlyData = _calculateMonthlyStats(taskProvider);
        final yearlyData = _calculateYearlyStats(taskProvider);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Productivity Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsSummary(taskProvider),
              const SizedBox(height: 24),
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              if (_selectedPeriod == 'week') ...[
                const Text(
                  'Weekly Productivity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildWeeklyBarChart(weeklyData),
              ] else if (_selectedPeriod == 'month') ...[
                const Text(
                  'Monthly Productivity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMonthlyLineChart(monthlyData),
              ] else ...[
                const Text(
                  'Yearly Productivity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildYearlyBarChart(yearlyData),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}