// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automaton_pack.dart';

// **************************************************************************
// WidgetGenerator
// **************************************************************************

class PlaceLever extends Widget {
  PlaceLever();

  @override
  Widget generate(Context context) => placeLever();
}

// **************************************************************************
// FileGenerator
// **************************************************************************

final File TickFile = File(
  '/tick',
  child: For.of(tick),
);

final File PlaceleverFile = File(
  '/internal/placelever',
  child: placelever,
);

final File LoadFile = File(
  '/load',
  child: For.of(load),
);

final File SummonnodeFile = File(
  '/internal/summonnode',
  child: For.of(summonnode),
);

final File AddstateFile = File(
  '/addstate',
  child: For.of(addstate),
);

final File AddedgeFile = File(
  '/addedge',
  child: For.of(addedge),
);

final File StepFile = File(
  '/step',
  child: For.of(step),
);

final File StartFile = File(
  '/start',
  child: For.of(start),
);

final File GivebookFile = File(
  '/givebook',
  child: givebook,
);

// **************************************************************************
// PackGenerator
// **************************************************************************

class AutomatonPack extends Widget {
  @override
  Widget generate(Context context) => Pack(
        name: 'automaton',
        files: automaton,
        main: File('tick', create: false),
        load: File('load', create: false),
      );
}
