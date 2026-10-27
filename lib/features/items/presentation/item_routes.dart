import 'package:flutter/material.dart';

import '../domain/item.dart';
import 'item_details_screen.dart';
import 'item_editor_screen.dart';

Future<void> openItemDetails(BuildContext context, String itemId) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemDetailsScreen(itemId: itemId),
      ),
    );

/// Opens the editor for a new item, or for [item].
Future<void> openItemEditor(BuildContext context, {Item? item}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ItemEditorScreen(item: item),
      ),
    );
