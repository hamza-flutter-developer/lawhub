# 🎯 Dart/Flutter Concepts - Quick Reference

## 📚 Essential Concepts You'll See in Your Code

---

## 1. **Widgets** (UI Components)

### StatelessWidget
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
```
- UI that doesn't change
- No state management needed

### StatefulWidget
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int counter = 0;
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $counter');
  }
}
```
- UI that can change
- Has `State` class
- Use `setState()` to update

---

## 2. **State Management**

### setState()
```dart
setState(() {
  counter = counter + 1; // Updates UI
});
```
- Updates UI when data changes
- Only works in StatefulWidget

### Variables
```dart
String name = 'John';
int age = 25;
bool isLoading = false;
List<String> items = ['a', 'b'];
```
- Store data
- Can be changed with `setState()`

---

## 3. **Async Programming**

### Future
```dart
Future<String> getData() async {
  return 'Hello';
}
```
- Value that comes later
- Use `async` keyword

### async/await
```dart
Future<void> loadData() async {
  String data = await getData(); // Wait for result
  print(data);
}
```
- `await`: Wait for Future to complete
- Must be in `async` function

### .then() and .onError()
```dart
getData().then((value) {
  print(value); // Success
}).onError((error, stackTrace) {
  print(error); // Error
});
```
- `.then()`: Execute after success
- `.onError()`: Handle errors

---

## 4. **Firebase Operations**

### Authentication
```dart
FirebaseAuth.instance.currentUser // Get logged-in user
FirebaseAuth.instance.signInWithEmailAndPassword(email, password)
FirebaseAuth.instance.signOut()
```

### Firestore - Read
```dart
// Read once
FirebaseFirestore.instance
  .collection('Users')
  .doc('user@email.com')
  .get()
  .then((doc) {
    print(doc.data());
  });

// Real-time updates
FirebaseFirestore.instance
  .collection('Users')
  .doc('user@email.com')
  .snapshots()
  .listen((snapshot) {
    print(snapshot.data());
  });
```

### Firestore - Write
```dart
// Create document
FirebaseFirestore.instance
  .collection('Users')
  .doc('user@email.com')
  .set({'name': 'John'});

// Update document
FirebaseFirestore.instance
  .collection('Users')
  .doc('user@email.com')
  .update({'name': 'Jane'});

// Add to collection
FirebaseFirestore.instance
  .collection('Users')
  .add({'name': 'John'});
```

---

## 5. **Navigation**

### Navigate to New Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);
```

### Navigate Back
```dart
Navigator.pop(context);
```

### Navigate and Replace
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

### Pass Data
```dart
// Pass data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfileScreen(userData: userData),
  ),
);

// Receive data
class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({required this.userData});
}
```

---

## 6. **Forms**

### Form Setup
```dart
final _formKey = GlobalKey<FormState>();
final _controller = TextEditingController();

Form(
  key: _formKey,
  child: TextFormField(
    controller: _controller,
    validator: (value) {
      if (value!.isEmpty) {
        return 'Required';
      }
      return null;
    },
  ),
)
```

### Validate Form
```dart
if (_formKey.currentState!.validate()) {
  // Form is valid
}
```

---

## 7. **Lists**

### ListView.builder
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

### GridView.builder
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(child: Text(items[index]));
  },
)
```

---

## 8. **StreamBuilder** (Real-time Data)

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('Users')
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          return Text(snapshot.data!.docs[index]['name']);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## 9. **Common Widgets**

### Text
```dart
Text('Hello World')
```

### Container
```dart
Container(
  width: 100,
  height: 100,
  color: Colors.blue,
  child: Text('Hello'),
)
```

### Row/Column
```dart
Row(
  children: [
    Text('A'),
    Text('B'),
  ],
)

Column(
  children: [
    Text('A'),
    Text('B'),
  ],
)
```

### Button
```dart
ElevatedButton(
  onPressed: () {
    print('Clicked');
  },
  child: Text('Click Me'),
)
```

### Image
```dart
Image.network('https://example.com/image.jpg')
Image.asset('assets/images/image.png')
Image.file(File('/path/to/image.jpg'))
```

---

## 10. **Error Handling**

### try-catch
```dart
try {
  // Code that might fail
  await someOperation();
} catch (e) {
  print('Error: $e');
}
```

### .onError()
```dart
someOperation()
  .then((value) {
    print('Success');
  })
  .onError((error, stackTrace) {
    print('Error: $error');
  });
```

---

## 11. **Text Controllers**

```dart
final _controller = TextEditingController();

TextFormField(
  controller: _controller,
)

// Get value
String text = _controller.text;

// Clear
_controller.clear();
```

---

## 12. **Conditional Rendering**

```dart
// If-else in UI
isLoading
  ? CircularProgressIndicator()
  : Text('Loaded')

// Or
if (isLoading) {
  return CircularProgressIndicator();
} else {
  return Text('Loaded');
}
```

---

## 13. **HTTP Requests**

```dart
import 'package:http/http.dart' as http;

Future<void> makeRequest() async {
  final response = await http.post(
    Uri.parse('https://api.example.com/data'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'key': 'value'}),
  );
  
  if (response.statusCode == 200) {
    print(response.body);
  }
}
```

---

## 14. **File Operations**

### Image Picker
```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);
File imageFile = File(image!.path);
```

---

## 15. **Common Patterns in Your Code**

### Loading State
```dart
bool isLoading = false;

setState(() {
  isLoading = true;
});

// Do operation
await someOperation();

setState(() {
  isLoading = false;
});
```

### Counter Pattern (Firestore)
```dart
var doc = await FirebaseFirestore.instance
  .collection('Requests')
  .doc('lawyer@email.com')
  .get();

int counter = doc['counter'];
counter++;

await FirebaseFirestore.instance
  .collection('Requests')
  .doc('lawyer@email.com')
  .update({
    'Request$counter': [...],
    'counter': counter,
  });
```

### Real-time Listener
```dart
FirebaseFirestore.instance
  .collection('ChatRooms')
  .doc('roomId')
  .collection('Chats')
  .orderBy('time', descending: true)
  .snapshots()
  .listen((snapshot) {
    // Update UI when new message arrives
  });
```

---

## 🎯 Quick Tips

1. **Always use `setState()`** when changing variables in StatefulWidget
2. **Use `async/await`** for Firebase operations
3. **Use `StreamBuilder`** for real-time data
4. **Validate forms** before submitting
5. **Handle errors** with try-catch or .onError()
6. **Use `Navigator`** to move between screens
7. **Pass data** through constructor parameters

---

## 📖 Study Order

1. Learn Widgets (StatelessWidget, StatefulWidget)
2. Learn State Management (setState, variables)
3. Learn Async (Future, async/await)
4. Learn Firebase (Auth, Firestore)
5. Learn Navigation
6. Learn Forms
7. Learn Lists
8. Learn StreamBuilder

---

Good luck! 🚀
