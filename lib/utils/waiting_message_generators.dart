import 'dart:math';

const List<String> _shutdownMessages = [
  'Finishing writing the show report..',
  'Finishing the cast timesheets...',
  'Having a sunday night office champagne...',
  'Emailing the show report...',
  'Cleaning up the office...',
  'Looking for the serviced apartment key...',
  'Finding out where thirsties is...',
  'Sending the timesheets...',
  'Remembering to stop the archival recording...',
  'Finishing the schedule for next week...',
  'Chasing up department heads for Show report blurbs...',
  'Writing audience reaction paragraph...'
];

String getShutdownWaitingMessage() {
  final rand = Random();

  return _shutdownMessages[rand.nextInt(_shutdownMessages.length)];
}
