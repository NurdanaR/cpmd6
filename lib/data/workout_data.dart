import '../models/fitness_model.dart';

/// Static workout catalog used when no remote workout API is configured.
class WorkoutData {
  WorkoutData._();

  /// Category → exercises map for the workout tab.
  static final Map<String, List<Exercise>> categories = {
    'Glutes': [
      Exercise(
        title: 'Glute Bridge',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=feded7145cf3becd4de0a765e64ea6702d59be3a-10139465-images-thumbs&n=13',
        instructions:
            'Lie on your back, lift your hips toward the ceiling, squeeze, and lower.',
      ),
      Exercise(
        title: 'Bulgarian Split Squats',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=90e87534adaf02a666c23365beca28fd7c9a2093-4374574-images-thumbs&n=13',
        instructions: 'Place one foot behind you on a bench and squat with the other leg.',
      ),
    ],
    'Chest': [
      Exercise(
        title: 'Bench Press',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=e402319368ba5a09d24ac40599794bc1770a9906-5886141-images-thumbs&n=13',
        instructions: 'Lie on a bench and press the barbell upward until your arms are extended.',
      ),
      Exercise(
        title: 'Push-ups',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=ee49b4ed527f9e9772c2ba85b795b28d42a01979-13226847-images-thumbs&n=13',
        instructions: 'Keep your body in a straight line and lower yourself by bending your elbows.',
      ),
    ],
    'Back': [
      Exercise(
        title: 'Lat Pulldowns',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=106564aa5a9761e1c1f0f5dfbd51022c463191a573dc91dc-11956207-images-thumbs&n=13',
        instructions: 'Pull the bar down to your upper chest while squeezing your shoulder blades.',
      ),
      Exercise(
        title: 'Seated Cable Rows',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=c913bc7ee0852cad4f68a0687d11a1f5cfd29e14-7549525-images-thumbs&n=13',
        instructions: 'Pull the handle toward your waist while keeping your back straight.',
      ),
    ],
    'Shoulders': [
      Exercise(
        title: 'Overhead Press',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=5308a56b8b2f1db0e3e0a4b4979f47da575e76c6-10995265-images-thumbs&n=13',
        instructions: 'Push the dumbbells or barbell directly overhead until your arms are straight.',
      ),
      Exercise(
        title: 'Lateral Raises',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=cedd4245f77051f80d49246f26ba7f3b-4080015-images-thumbs&n=13',
        instructions: 'Lift the weights out to your sides until they reach shoulder height.',
      ),
    ],
    'Legs': [
      Exercise(
        title: 'Leg Extensions',
        imageUrl: 'https://ice-profy.ru/wp-content/uploads/2023/06/5.jpeg',
        instructions: 'Sit in the machine and extend your legs until they are straight, then lower slowly.',
      ),
      Exercise(
        title: 'Squats',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=5dc0bcc0727c965267afdf75be64b23a3e98745a-9229208-images-thumbs&n=13',
        instructions: 'Lower your hips as if sitting in a chair, keeping your chest up.',
      ),
      Exercise(
        title: 'Leg Press',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=a99884acea2ba733e0619609c438a562a159da2d-12938298-images-thumbs&n=13',
        instructions: 'Push the platform away using your legs, then slowly bring it back.',
      ),
    ],
    'Biceps': [
      Exercise(
        title: 'Dumbbell Curls',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=267936f7e7ee43ac1329fd1fdcfb7f947a5bf222-4298456-images-thumbs&n=13',
        instructions: 'Curl the weights toward your shoulders while keeping elbows tucked.',
      ),
    ],
    'Triceps': [
      Exercise(
        title: 'Tricep Dips',
        imageUrl:
            'https://avatars.mds.yandex.net/i?id=1eca940f4b3abbae05fdc57237fff59ea9eb8fb4-4936819-images-thumbs&n=13',
        instructions: 'Lower your body using your arms on a bench, then push back up.',
      ),
    ],
  };

  /// Featured workout blocks for the carousel.
  static final List<WorkoutPlan> plans = [
    WorkoutPlan(
      tag: 'Block 1',
      title: 'Leg Day',
      imgUrl: 'https://m.media-amazon.com/images/I/61xQsD1lVaL._AC_UF1000,1000_QL80_.jpg',
      exercises: [
        BlockExercise(
          name: 'Barbell Squats',
          subtitle: '4x12',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=5dc0bcc0727c965267afdf75be64b23a3e98745a-9229208-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Leg Press',
          subtitle: '4x12',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=a99884acea2ba733e0619609c438a562a159da2d-12938298-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Seated Leg Abductions',
          subtitle: '4x12',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=488ad7ba5f8a2d33db120419ba6c67e3_l-9181330-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Hamstring Curls',
          subtitle: '4x12',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=1d6854e4b3fe007335329776c8c132d00c6e0213-10026462-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Leg Extensions',
          subtitle: '4x12',
          imageUrl: 'https://i2.wp.com/training.fit/wp-content/uploads/2020/03/beinstrecken-geraet-1.png',
        ),
        BlockExercise(
          name: 'Seated Leg Adductions',
          subtitle: '4x12',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=f7d379fb6769a94cbe5bb111ec107d6c_l-10637415-images-thumbs&n=13',
        ),
      ],
    ),
    WorkoutPlan(
      tag: 'Block 2',
      title: 'Arm Day',
      imgUrl: 'https://i.ytimg.com/vi/2PohL-eJT6w/maxresdefault.jpg',
      exercises: [
        BlockExercise(
          name: 'Dumbbell Curls',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=267936f7e7ee43ac1329fd1fdcfb7f947a5bf222-4298456-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Tricep Dips',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=1eca940f4b3abbae05fdc57237fff59ea9eb8fb4-4936819-images-thumbs&n=13',
        ),
      ],
    ),
    WorkoutPlan(
      tag: 'Block 3',
      title: 'Full Body',
      imgUrl: 'https://i.ytimg.com/vi/wRgdl4SGWIw/maxresdefault.jpg',
      exercises: [
        BlockExercise(
          name: 'Deadlifts',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=9ea536440e21379e403d1f37e19f95701a590216-10810237-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Push-ups',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=ee49b4ed527f9e9772c2ba85b795b28d42a01979-13226847-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Plank',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=84e3146e4921616c68e3d8c1995a97926b485987-10121543-images-thumbs&n=13',
        ),
      ],
    ),
    WorkoutPlan(
      tag: 'Block 4',
      title: 'Back Day',
      imgUrl: 'https://i.ytimg.com/vi/lcZJxl_ihyA/maxresdefault.jpg',
      exercises: [
        BlockExercise(
          name: 'Lat Pulldowns',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=106564aa5a9761e1c1f0f5dfbd51022c463191a573dc91dc-11956207-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Seated Cable Rows',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=c913bc7ee0852cad4f68a0687d11a1f5cfd29e14-7549525-images-thumbs&n=13',
        ),
        BlockExercise(
          name: 'Pull-ups',
          imageUrl:
              'https://avatars.mds.yandex.net/i?id=b5606d4e207b1d40003b41317540a9c693a90623-10807537-images-thumbs&n=13',
        ),
      ],
    ),
  ];
}
