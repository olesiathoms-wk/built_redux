library test_counter;

import 'dart:async';

import 'package:built_redux/built_redux.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

part 'test_counter.g.dart';

/// Used to test code generation when the generic type of an action is a
/// `typedef`
typedef dynamic FooTypedef(MiddlewareApi api);

// BaseCounter

abstract class BaseCounterActions extends ReduxActions {
  ActionDispatcher<int> increment;
  ActionDispatcher<int> decrement;
  ActionDispatcher<Null> incrementOne;
  ActionDispatcher<FooTypedef> foo;

  NestedCounterActions nestedCounterActions;
  MiddlewareActions middlewareActions;

  BaseCounterActions._();
  factory BaseCounterActions() => new _$BaseCounterActions();
}

_baseIncrement(
        BaseCounter state, Action<int> action, BaseCounterBuilder builder) =>
    builder..count = state.count + action.payload;

_baseDecrement(
        BaseCounter state, Action<int> action, BaseCounterBuilder builder) =>
    builder..count = state.count - action.payload;

_baseIncrementOne(
        BaseCounter state, Action<Null> action, BaseCounterBuilder builder) =>
    builder..count = state.count + 1;

final _baseReducer = (new ReducerBuilder<BaseCounter, BaseCounterBuilder>()
      ..add(BaseCounterActionsNames.increment, _baseIncrement)
      ..add(BaseCounterActionsNames.decrement, _baseDecrement)
      ..add(BaseCounterActionsNames.incrementOne, _baseIncrementOne))
    .build();

// Built Reducer
abstract class BaseCounter extends Object
    with BaseCounterReducer
    implements Built<BaseCounter, BaseCounterBuilder> {
  int get count;

  BuiltList<int> get indexOutOfRangeList;

  NestedCounter get nestedCounter;

  @override
  get reducer => _baseReducer;

  // Built value constructor
  BaseCounter._();
  factory BaseCounter() => new _$BaseCounter._(
        count: 1,
        indexOutOfRangeList: new BuiltList<int>(),
        nestedCounter: new NestedCounter(),
      );
}

// Nested Counter

abstract class NestedCounterActions extends ReduxActions {
  ActionDispatcher<int> increment;
  ActionDispatcher<int> decrement;
  ActionDispatcher<Null> incrementOne;
  ActionDispatcher<FooTypedef> fooTypedef;

  NestedCounterActions._();
  factory NestedCounterActions() => new _$NestedCounterActions();
}

_nestedIncrement(NestedCounter state, Action<int> action,
        NestedCounterBuilder builder) =>
    builder..count = state.count + action.payload;

_nestedDecrement(NestedCounter state, Action<int> action,
        NestedCounterBuilder builder) =>
    builder..count = state.count - action.payload;

_nestedIncrementOne(NestedCounter state, Action<Null> action,
        NestedCounterBuilder builder) =>
    builder..count = state.count + 1;

final _nestedReducer =
    (new ReducerBuilder<NestedCounter, NestedCounterBuilder>()
          ..add(NestedCounterActionsNames.increment, _nestedIncrement)
          ..add(NestedCounterActionsNames.decrement, _nestedDecrement)
          ..add(NestedCounterActionsNames.incrementOne, _nestedIncrementOne))
        .build();

abstract class NestedCounter extends Object
    with NestedCounterReducer
    implements Built<NestedCounter, NestedCounterBuilder> {
  int get count;

  get reducer => _nestedReducer;

  // Built value constructor
  NestedCounter._();
  factory NestedCounter() => new _$NestedCounter._(count: 1);
}

// Middleware

abstract class MiddlewareActions extends ReduxActions {
  ActionDispatcher<int> increment;

  MiddlewareActions._();
  factory MiddlewareActions() => new _$MiddlewareActions();
}

var counterMiddleware = (new MiddlewareBuilder<BaseCounter, BaseCounterBuilder,
        BaseCounterActions>()
      ..add(MiddlewareActionsNames.increment, _doubleIt))
    .build();

_doubleIt(
    MiddlewareApi<BaseCounter, BaseCounterBuilder, BaseCounterActions> api,
    ActionHandler next,
    Action<int> action) {
  api.actions.increment(api.state.count * 2);
  next(action);
}

// typedef

NextActionHandler fooTypedefMiddleware(
        MiddlewareApi<BaseCounter, BaseCounterBuilder, BaseCounterActions>
            api) =>
    (ActionHandler next) => (Action a) {
          if (a.payload is FooTypedef) {
            a.payload(api);
          }

          next(a);
        };

// Change handler

createChangeHandler(Completer comp) => (new StoreChangeHandlerBuilder<
    BaseCounter, BaseCounterBuilder, BaseCounterActions>()
  ..add(BaseCounterActionsNames.increment, (change) => comp.complete(change)));
