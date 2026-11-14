import 'package:flutter/material.dart';
import 'package:mybooks/Book_Model/required.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    required this.book,
    this.initialRating,
    super.key,
  });

  final Required book;
  final int? initialRating;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late int _rating = widget.initialRating ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(widget.book.author),
            Text(widget.book.genre),
            const SizedBox(height: 24),
            const Text(
              'Your rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                final starRating = index + 1;
                return IconButton(
                  tooltip:
                      'Rate $starRating ${starRating == 1 ? 'star' : 'stars'}',
                  onPressed: () => setState(() => _rating = starRating),
                  icon: Icon(
                    starRating <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _rating == 0 ? null : () => Navigator.pop(context, _rating),
                child: const Text('Save rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
