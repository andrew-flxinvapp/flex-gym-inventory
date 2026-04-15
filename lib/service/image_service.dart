import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Simple image metadata model stored alongside image files.
class ImageItem {
	final String id;
	final String filename;
	final String? title;
	final DateTime createdAt;

	ImageItem({
		required this.id,
		required this.filename,
		this.title,
		DateTime? createdAt,
	}) : createdAt = createdAt ?? DateTime.now();

	String get path => filename;

	Map<String, dynamic> toJson() => {
				'id': id,
				'filename': filename,
				'title': title,
				'createdAt': createdAt.toIso8601String(),
			};

	factory ImageItem.fromJson(Map<String, dynamic> json) => ImageItem(
				id: json['id'] as String,
				filename: json['filename'] as String,
				title: json['title'] as String?,
				createdAt: DateTime.parse(json['createdAt'] as String),
			);
}

/// Service providing simple CRUD for storing image files and metadata.
class ImageService {
	static const _metaKey = 'fgi_image_metadata_v1';
	static final Uuid _uuid = Uuid();

	ImageService._();
	static final ImageService instance = ImageService._();

	Future<Directory> _imagesDir() async {
		final dir = await getApplicationDocumentsDirectory();
		final images = Directory(p.join(dir.path, 'images'));
		if (!await images.exists()) await images.create(recursive: true);
		return images;
	}

	Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

	Future<Map<String, ImageItem>> _loadMetaMap() async {
		final prefs = await _prefs();
		final jsonStr = prefs.getString(_metaKey);
		if (jsonStr == null) return {};
		final Map<String, dynamic> raw = json.decode(jsonStr) as Map<String, dynamic>;
		return raw.map((k, v) => MapEntry(k, ImageItem.fromJson(v as Map<String, dynamic>)));
	}

	Future<void> _saveMetaMap(Map<String, ImageItem> map) async {
		final prefs = await _prefs();
		final serial = map.map((k, v) => MapEntry(k, v.toJson()));
		await prefs.setString(_metaKey, json.encode(serial));
	}

	/// Add an image from raw bytes. Returns the created `ImageItem`.
	Future<ImageItem> addImage(Uint8List bytes, {String? filename, String? title}) async {
		final id = _uuid.v4();
		final ext = filename != null ? p.extension(filename) : '.jpg';
		final fname = '${id}${ext.isEmpty ? '.jpg' : ext}';
		final dir = await _imagesDir();
		final filePath = p.join(dir.path, fname);
		final file = File(filePath);
		await file.writeAsBytes(bytes, flush: true);

		final item = ImageItem(id: id, filename: filePath, title: title);
		final meta = await _loadMetaMap();
		meta[id] = item;
		await _saveMetaMap(meta);
		return item;
	}

	/// Return all saved images (metadata only).
	Future<List<ImageItem>> getAllImages() async {
		final meta = await _loadMetaMap();
		final list = meta.values.toList();
		list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
		return list;
	}

	/// Get metadata for a single image by id.
	Future<ImageItem?> getImage(String id) async {
		final meta = await _loadMetaMap();
		return meta[id];
	}

	/// Update an image's bytes and/or title. If `bytes` is provided the file is replaced.
	Future<ImageItem?> updateImage(String id, {Uint8List? bytes, String? title}) async {
		final meta = await _loadMetaMap();
		final item = meta[id];
		if (item == null) return null;

		String filename = item.filename;
		if (bytes != null) {
			final file = File(filename);
			if (!await file.exists()) {
				// If original file missing, write a new one in images dir.
				final dir = await _imagesDir();
				filename = p.join(dir.path, p.basename(filename));
			}
			await File(filename).writeAsBytes(bytes, flush: true);
		}

		final updated = ImageItem(id: id, filename: filename, title: title ?? item.title, createdAt: item.createdAt);
		meta[id] = updated;
		await _saveMetaMap(meta);
		return updated;
	}

	/// Delete an image file and its metadata.
	Future<bool> deleteImage(String id) async {
		final meta = await _loadMetaMap();
		final item = meta.remove(id);
		if (item == null) return false;
		await _saveMetaMap(meta);
		try {
			final f = File(item.filename);
			if (await f.exists()) await f.delete();
		} catch (_) {}
		return true;
	}

	/// Helper to get the `File` for an image id, or null if not present.
	Future<File?> fileFor(String id) async {
		final item = await getImage(id);
		if (item == null) return null;
		final f = File(item.filename);
		return await f.exists() ? f : null;
	}
}

