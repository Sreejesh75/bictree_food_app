import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _defaultStorageKey = 'bictree_persisted_cart_v1';
  String? _activeUserId;

  CartBloc() : super(const CartState()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<RestoreCartItemEvent>(_onRestoreCartItem);
    on<ClearCartEvent>(_onClearCart);
    on<SaveAndClearCartEvent>(_onSaveAndClearCart);
  }

  String _getStorageKey([String? userId]) {
    final id = userId ?? _activeUserId;
    if (id != null && id.isNotEmpty) {
      return 'bictree_cart_user_$id';
    }
    return _defaultStorageKey;
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    if (event.userId != null) {
      _activeUserId = event.userId;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final items = decoded
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(items: items, isLoading: false));
        return;
      }
    } catch (_) {}
    emit(state.copyWith(items: const [], isLoading: false));
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere(
      (item) => item.recipe.id == event.recipe.id,
    );

    if (existingIndex >= 0) {
      final existingItem = currentItems[existingIndex];
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + event.quantity,
      );
    } else {
      currentItems.add(
        CartItem(recipe: event.recipe, quantity: event.quantity),
      );
    }

    emit(state.copyWith(items: currentItems));
    await _saveToStorage(currentItems);
  }

  Future<void> _onUpdateQuantity(
    UpdateCartQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.recipe.id == event.recipeId,
    );

    if (index >= 0) {
      if (event.quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index] = currentItems[index].copyWith(
          quantity: event.quantity,
        );
      }
      emit(state.copyWith(items: currentItems));
      await _saveToStorage(currentItems);
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.recipe.id == event.recipeId);

    emit(state.copyWith(items: currentItems));
    await _saveToStorage(currentItems);
  }

  Future<void> _onRestoreCartItem(
    RestoreCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = List<CartItem>.from(state.items);
    if (event.index != null &&
        event.index! >= 0 &&
        event.index! <= currentItems.length) {
      currentItems.insert(event.index!, event.item);
    } else {
      currentItems.add(event.item);
    }

    emit(state.copyWith(items: currentItems));
    await _saveToStorage(currentItems);
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(items: const []));
    await _saveToStorage(const []);
  }

  Future<void> _onSaveAndClearCart(
    SaveAndClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    await _saveToStorage(state.items);
    emit(state.copyWith(items: const []));
    _activeUserId = null;
  }

  Future<void> _saveToStorage(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_getStorageKey(), encoded);
    } catch (_) {}
  }
}
