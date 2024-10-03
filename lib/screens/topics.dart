import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/authorizationBloc.dart';
import 'Homepage.dart';
import 'drawer_file.dart';

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  State<Topics> createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
  int selectedTopicIndex = 0;

  final List<String> topics = [
    'Faith',
    'Sacrifice',
    'Blessings',
    'Tithe',
  ];

  final List<String> sermons = [
    'Lent',
    'Salvation',
    'Gratitude',
  ];

  final List<Map<String, String>> speakers = [
    {'name': 'Pastor Tony', 'image': 'images/pastor_tony.jpeg'},
    {'name': 'Kuhani Musa', 'image': 'images/kuhani_musa.jpeg'},
    {'name': 'Rose Shaboka', 'image': 'images/rose_shaboka.jpeg'},
    {'name': 'Nick Shaboka', 'image': 'images/nick_shaboka.jpeg'},
  ];

  final Map<String, Map<String, String>> scriptures = {
    'Faith': {
      'text': 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      'reference': 'Joshua 1:9',
      'image': 'images/scripture_image.jpeg'
    },
    'Sacrifice': {
      'text': 'Greater love has no one than this: to lay down one’s life for one’s friends.',
      'reference': 'John 15:13',
      'image': 'images/scripture_image.jpeg'
    },
    'Blessings': {
      'text': 'The LORD bless you and keep you; the LORD make his face shine on you and be gracious to you.',
      'reference': 'Numbers 6:24-25',
      'image': 'images/scripture_image.jpeg'
    },
    'Tithe': {
      'text': 'Bring the whole tithe into the storehouse, that there may be food in my house. Test me in this, says the LORD Almighty, and see if I will not throw open the floodgates of heaven and pour out so much blessing that there will not be room enough to store it.',
      'reference': 'Malachi 3:10',
      'image': 'images/scripture_image.jpeg'
    },
  };

  void _onTopicTapped(int index) {
    setState(() {
      selectedTopicIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthorizationBloc authorizationBloc = Provider.of<AuthorizationBloc>(context);
    String selectedTopic = topics[selectedTopicIndex];
    String scriptureText = scriptures[selectedTopic]!['text']!;
    String scriptureReference = scriptures[selectedTopic]!['reference']!;
    String backgroundImage = scriptures[selectedTopic]!['image']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Topics"),
        centerTitle: true,
      ),
      drawer: const Drawer(
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
        child: CustomDrawerList(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    "Topics",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(topics.length, (index) {
                    bool isSelected = selectedTopicIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _onTopicTapped(index),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(topics[index]),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          scriptureText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          scriptureReference,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    "Sermons",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(sermons.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              image: DecorationImage(
                                image: AssetImage('images/${sermons[index].toLowerCase()}.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 5),
                          Text(sermons[index]),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    "Speakers",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(speakers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(speakers[index]['image']!),
                          ),
                          const SizedBox(height: 5),
                          Text(speakers[index]['name']!),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

