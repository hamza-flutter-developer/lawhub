import 'package:flutter/material.dart';


class test4 extends StatefulWidget {
  @override
  _test4State createState() => _test4State();
}

class _test4State extends State<test4> {
  double _rating = 0.0;
  String _feedback = '';

  void _submitFeedback() {
    print('Rating: $_rating');
    print('Feedback: $_feedback');
    // Reset rating and feedback
    setState(() {
      _rating = 0;
      _feedback = '';
    });
  }

  Widget _buildStar(int index) {
    if (index < _rating) {
      return Icon(Icons.star, color: Colors.yellow);
    } else {
      return Icon(Icons.star_border, color: Colors.yellow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating Feedback'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Rate your experience:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: _buildStar(index),
                );
              }),
            ),
            SizedBox(height: 20),
            Text(
              'Feedback:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _feedback = value;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}