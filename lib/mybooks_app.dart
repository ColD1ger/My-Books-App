import 'package:flutter/material.dart';
import 'package:mybooks/Book_Model/books.dart' show books;
import 'package:mybooks/Book_Model/required.dart';
import 'package:mybooks/details_page.dart';

class Book {
  final String title;
  final String author;
  final String genre;
  final String booksid;

  const Book({
    required this.title,
    required this.author,
    required this.genre,
    required this.booksid,
  });
}

class MybooksApp extends StatefulWidget {
  const MybooksApp({super.key});

  @override
  State<MybooksApp> createState() => _MybooksAppState();
}

class _MybooksAppState extends State<MybooksApp> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _checkedBooks = {};
  final Map<int, int> _bookRatings = {};
  String _selectedGenre = 'All';

  List<String> get genres {
    final uniqueGenres = books.map((book) => book.genre).toSet().toList();
    uniqueGenres.sort();
    return ['All', ...uniqueGenres];
  }

  List<Required> get filteredBooks {
    final query = _searchController.text.trim().toLowerCase();

    return books.where((book) {
      final matchesGenre =
          _selectedGenre == 'All' || book.genre == _selectedGenre;
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);
      return matchesGenre && matchesQuery;
    }).toList();
  }

  void _deleteBook(Required book) {
    final bookIndex = books.indexOf(book);
    if (bookIndex == -1) return;

    setState(() {
      books.removeAt(bookIndex);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${book.title}" deleted'),
          action: SnackBarAction(
            label: 'Cancel',
            onPressed: () {
              if (!mounted) return;

              setState(() {
                final restoreIndex =
                    bookIndex > books.length ? books.length : bookIndex;
                books.insert(restoreIndex, book);
              });
            },
          ),
        ),
      );
  }

  Future<void> _openBookDetails(Required book) async {
    final rating = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          book: book,
          initialRating: _bookRatings[book.booksid],
        ),
      ),
    );

    if (rating == null || !mounted) return;

    setState(() {
      _bookRatings[book.booksid] = rating;
      _checkedBooks[book.booksid] = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleBooks = filteredBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Books App',
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Books List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search books and authors',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: genres.map((genre) {
                        final isSelected = _selectedGenre == genre;
                        return ChoiceChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: visibleBooks.isEmpty
                ? const Center(
                    child: Text('No books match your filters.'),
                  )
                : ListView.separated(
                    itemCount: visibleBooks.length,
                    itemBuilder: (context, index) {
                      final book = visibleBooks[index];
                      final isChecked = _checkedBooks[book.booksid] ?? false;

                      return Dismissible(
                        key: ValueKey(book.booksid),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteBook(book),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 90),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 227, 227, 227),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _checkedBooks[book.booksid] =
                                          newValue ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _openBookDetails(book),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  book.title,
                                                  style: TextStyle(
                                                    decoration: isChecked
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                              if (isChecked)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'Read',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green[900],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(book.author),
                                          Text(book.genre),
                                          if (_bookRatings
                                              .containsKey(book.booksid))
                                            Row(
                                              children: List.generate(
                                                _bookRatings[book.booksid]!,
                                                (_) => const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                  ),
          ),
        ],
      ),
    );
  }
}
