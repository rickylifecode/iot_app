# apply_lab3.ps1
# Run from the iot_app project folder (the one that contains pubspec.yaml).
# It will:
#   1. create lib\firestore_products_page.dart (if missing)
#   2. add the two imports to lib\main.dart
#   3. add two buttons ("Firestore products", "Manage products") to the store page
#   4. switch the two pages to your app's blue colour
# A backup of your main.dart is saved as main.dart.bak in the project folder.

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path 'lib\main.dart')) {
  Write-Host 'ERROR: lib\main.dart not found. Open PowerShell in the iot_app folder first.' -ForegroundColor Red
  exit 1
}

# ------------------------------------------------------------------
# 1) Read page (Lab 3 exercise)
# ------------------------------------------------------------------
$readPage = @'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Lab 3 - reads the 'products' collection from Cloud Firestore.
/// StreamBuilder listens to snapshots(), so the list updates live
/// whenever you add, edit or delete a document.
class FirestoreProductsPage extends StatefulWidget {
  const FirestoreProductsPage({super.key});

  @override
  State<FirestoreProductsPage> createState() => _FirestoreProductsPageState();
}

class _FirestoreProductsPageState extends State<FirestoreProductsPage> {
  final Stream<QuerySnapshot> _productsStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Products',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                  'No products yet.\nAdd documents in the Firebase console.',
                  textAlign: TextAlign.center),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name =
                  (data['Name'] ?? data['name'] ?? 'Unnamed').toString();
              final price = data['Price'] ?? data['price'];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE3E5EE)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4F46E5),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle:
                      Text(price != null ? 'Price: $price' : 'No price set'),
                  trailing: Text(
                    doc.id.length > 6 ? '${doc.id.substring(0, 6)}...' : doc.id,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
'@

if (Test-Path 'lib\firestore_products_page.dart') {
  Write-Host '[skip] lib\firestore_products_page.dart already exists'
} else {
  [IO.File]::WriteAllText((Join-Path (Get-Location) 'lib\firestore_products_page.dart'), $readPage, $utf8)
  Write-Host '[ok]   created lib\firestore_products_page.dart'
}

# ------------------------------------------------------------------
# 2) Check the manage page exists
# ------------------------------------------------------------------
if (-not (Test-Path 'lib\manage_products_page.dart')) {
  Write-Host '[WARN] lib\manage_products_page.dart is missing. Copy it into lib first.' -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 3) Blue theme for both pages (your app uses 0A66C2)
# ------------------------------------------------------------------
foreach ($f in 'lib\firestore_products_page.dart', 'lib\manage_products_page.dart') {
  if (Test-Path $f) {
    $t = [IO.File]::ReadAllText((Join-Path (Get-Location) $f))
    if ($t.Contains('4F46E5')) {
      [IO.File]::WriteAllText((Join-Path (Get-Location) $f), $t.Replace('4F46E5', '0A66C2'), $utf8)
      Write-Host "[ok]   recoloured $f"
    }
  }
}

# ------------------------------------------------------------------
# 4) Patch main.dart
# ------------------------------------------------------------------
$mainPath = Join-Path (Get-Location) 'lib\main.dart'
Copy-Item $mainPath (Join-Path (Get-Location) 'main.dart.bak') -Force
$main = [IO.File]::ReadAllText($mainPath)
$changed = $false

# 4a) imports
$anchorImport = "import 'firebase_options.dart';"
$newImports = ''
if (-not $main.Contains("import 'firestore_products_page.dart';")) {
  $newImports += "`r`nimport 'firestore_products_page.dart';"
}
if (-not $main.Contains("import 'manage_products_page.dart';")) {
  $newImports += "`r`nimport 'manage_products_page.dart';"
}
if ($newImports -ne '') {
  if ($main.Contains($anchorImport)) {
    $idx = $main.IndexOf($anchorImport)
    $main = $main.Insert($idx + $anchorImport.Length, $newImports)
    $changed = $true
    Write-Host '[ok]   added imports to main.dart'
  } else {
    Write-Host "[WARN] could not find $anchorImport in main.dart - add the imports by hand" -ForegroundColor Yellow
  }
} else {
  Write-Host '[skip] imports already present'
}

# 4b) the two chips, inserted at the end of the chip row in _categoryFilters
$chips = ''
if (-not $main.Contains("Text('Firestore products')")) {
  $chips += @'

        ActionChip(
          avatar: const Icon(Icons.cloud_outlined, size: 17),
          label: const Text('Firestore products'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FirestoreProductsPage()),
          ),
        ),
'@
}
if (-not $main.Contains("Text('Manage products')")) {
  $chips += @'

        ActionChip(
          avatar: const Icon(Icons.edit_note_rounded, size: 17),
          label: const Text('Manage products'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageProductsPage()),
          ),
        ),
'@
}

if ($chips -ne '') {
  $pattern = '(?s)(color:\s*_favoritesOnly\s*\?\s*_AppColors\.green\s*:\s*_AppColors\.line\),\s*\),)(\s*\],\s*\);\s*\}\s*Widget _productGrid)'
  if ([regex]::IsMatch($main, $pattern)) {
    $main = [regex]::Replace($main, $pattern, {
      param($m)
      $m.Groups[1].Value + $chips.TrimEnd() + $m.Groups[2].Value
    })
    $changed = $true
    Write-Host '[ok]   added buttons to the store page'
  } else {
    Write-Host '[WARN] could not find the chip row in main.dart - add the chips by hand' -ForegroundColor Yellow
  }
} else {
  Write-Host '[skip] buttons already present'
}

if ($changed) {
  [IO.File]::WriteAllText($mainPath, $main, $utf8)
}

# ------------------------------------------------------------------
# 5) Check the package
# ------------------------------------------------------------------
if (Select-String -Path 'pubspec.yaml' -Pattern 'cloud_firestore' -Quiet) {
  Write-Host '[ok]   cloud_firestore is in pubspec.yaml'
} else {
  Write-Host '[WARN] cloud_firestore is NOT in pubspec.yaml - add: cloud_firestore: ^5.4.3 and run flutter pub get' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Done. Now run:  flutter run -d chrome' -ForegroundColor Green
