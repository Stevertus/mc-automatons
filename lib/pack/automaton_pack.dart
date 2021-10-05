import 'package:objd/core.dart';

part 'automaton_pack.g.dart';

@Pck(name: 'automaton', load: 'load', main: 'tick')
final automaton = [
  TickFile,
  LoadFile,
  GivebookFile,
  PlaceleverFile,
  AddstateFile,
  AddedgeFile,
  SummonnodeFile,
  StartFile,
  StepFile,
];

final states = Scoreboard('states');
final dir = {
  Location.rel(z: 1, y: -1): Rotation.checkSouth,
  Location.rel(z: -1, y: -1): Rotation.checkNorth,
  Location.rel(x: 1, y: -1): Rotation.checkEast,
  Location.rel(x: -1, y: -1): Rotation.checkWest,
};

@Func(path: '/')
final tick = <Widget>[
  /// Write your main code here
  Execute.asat(Entity(tags: ['automaton']), children: [
    If(
      Condition.not(Location.here()),
      then: [
        Kill(Entity.Self()),
      ],
    ),
    Entity.Self(tags: ['start']).as(
      children: [
        Particle(Particles.flame, location: Location.rel(y: 1)),
      ],
    ),
    Entity.Self(tags: ['final']).as(
      children: [Particle(Particles.portal, location: Location.rel(y: 1))],
    ),
  ])
];
@Func(path: '/internal/')
final Widget placelever = PlaceLever();

@Func(path: '/')
final load = [
  /// Write your load code here
  states,
];

@Func(path: '/internal/')
final summonnode = [
  Execute(children: [
    ArmorStand.staticMarker(
      Location.here(),
      tags: ['automaton', 'create'],
      name: TextComponent('state'),
      nameVisible: true,
      small: true,
      head: Item(Items.campfire, count: 1),
      pose: Pose(head: [90]),
    )
  ]).center(0.1),
  for (var k in dir.entries)
    Execute.as(
      Entity.Self(horizontalRotation: k.value),
      children: [
        Teleport(Entity.Self(), to: Location.here(), facing: k.key),
      ],
    ).asat(Entity(limit: 1, tags: ['create']).sort(Sort.nearest)),
];
@Func(path: '/')
final addstate = [
  SummonnodeFile.run(),
  Execute.as(
    Entity(limit: 1, tags: ['create']),
    children: [Tag('state'), Tag('create').remove()],
  ),
  SetBlock(Blocks.redstone_lamp),
];
@Func(path: '/')
final addedge = [
  SummonnodeFile.run(),
  Execute.as(
    Entity(limit: 1, tags: ['create']),
    children: [
      Data.merge(Entity.Self(), nbt: {'CustomNameVisible': false}),
      Tag('transition'),
      Tag('create').remove(),
    ],
  ),
  SetBlock(Blocks.note_block),
];
@Func(path: '/')
final step = [
  Execute.asat(Entity(tags: ['state']), children: [
    If(
      Block.nbt(Blocks.redstone_lamp, states: {'lit': true}),
      then: [Tag.add('active')],
    ),
    PlaceleverFile.run(),
  ]),
  Execute.asat(Entity(tags: ['transition']), children: [
    Tag.remove('active'),
    PlaceleverFile.run(),
  ]),
  Execute.asat(Entity(tags: ['head']), children: [
    Teleport(Entity.Self(), to: Location.rel(x: 1)),
    Clone(Area.rel(), to: Location.glob(y: 20)),
  ]),
  If(Condition.block(Location.glob(y: 20), block: Blocks.light_gray_concrete),
      then: [
        If(
          Entity(tags: ['final', 'state', 'active']),
          assignTag: Entity.Player(),
          then: [
            Title(
              Entity.All(),
              show: [TextComponent('Accepted', color: Color.Green)],
            )
          ],
          orElse: [
            Title(
              Entity.All(),
              show: [TextComponent('Declined', color: Color.Red)],
            )
          ],
        )
      ]),
  Timeout(
    'check_transitions',
    children: [
      Execute.asat(Entity(tags: ['state']), children: [
        Tag.remove('active'),
      ]),
      Execute.asat(Entity(tags: ['transition']), children: [
        Tag.add('active'),
      ]).If(Condition.and([
        Block.nbt(Blocks.note_block, states: {'powered': true}),
        Condition.blocks(Area.rel(y1: 1, y2: 1), compare: Location.glob(y: 20))
      ])),
      Execute.asat(Entity(tags: ['automaton']), children: [
        PlaceleverFile.run(),
      ]),
    ],
    ticks: 10,
  )
];
@Func(path: '/')
final start = [
  Teleport(Entity(tags: ['head']), to: Location.glob(y: 20.1, z: -2, x: -1)),
  Execute.asat(Entity(tags: ['automaton']), children: [
    Tag.remove('active'),
    PlaceleverFile.run(),
  ]),
  Tag.add('active', entity: Entity(tags: ['start'])),
  StepFile.run(),
];

@Func(path: '/')
final givebook = Give(
  Entity.Self(),
  item: Item.Book([
    BookPage([
      TextComponent(
        'Summon State\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/function automaton:addstate'),
        ),
      ),
      TextComponent(
        'Summon Transition\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/function automaton:addedge'),
        ),
      ),
      TextComponent(
        'Make Start\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/tag @e[tag=state,sort=nearest,limit=1] add start'),
        ),
      ),
      TextComponent(
        'Make Final\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/tag @e[tag=state,sort=nearest,limit=1] add final'),
        ),
      ),
      TextComponent(
        'Start\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/function automaton:start'),
        ),
      ),
      TextComponent(
        'Step\n\n',
        clickEvent: TextClickEvent.run_command(
          Command('/function automaton:step'),
        ),
      ),
    ])
  ]),
);

@Wdg
Widget placeLever() {
  return For.of([
    for (var k in dir.entries)
      Entity.Self(horizontalRotation: k.value, tags: ['active']).as(
        children: [
          SetBlock(Blocks.redstone_block, location: k.key),
        ],
      ),
    for (var k in dir.entries)
      Entity.Self(horizontalRotation: k.value).not(tags: ['active']).as(
        children: [
          SetBlock(Blocks.light_gray_concrete, location: k.key),
        ],
      ),
  ]);
}
