import 'package:animation_types/pages/shop_pillow_animation_page.dart';
import 'package:animation_types/pages/button_scale_demo.dart';
import 'package:animation_types/pages/button_size_physics.dart';
import 'package:animation_types/pages/grid_motion_controllers_screen.dart';
import 'package:animation_types/pages/grid_smooth_fantastic_physics.dart';
import 'package:animation_types/pages/grid_z_axis_screen.dart';
import 'package:animation_types/pages/listview_animations_screen.dart';
import 'package:animation_types/pages/motion_style_grid.dart';
import 'package:animation_types/pages/page_view_screen.dart';
import 'package:animation_types/pages/pageview_animation3.dart';
import 'package:animation_types/pages/pageview_animation5.dart';
import 'package:animation_types/pages/pageview_animation6.dart';
import 'package:animation_types/pages/pageview_animation_2.dart';
import 'package:animation_types/pages/pageview_animation_4.dart';
import 'package:animation_types/pages/pageview_hero_animation.dart';
import 'package:animation_types/pages/physics_tab_example_two.dart';
import 'package:animation_types/pages/physics_tab_with_sliders.dart';
import 'package:animation_types/pages/shop_pillow_circel_round.dart';
import 'package:animation_types/pages/shop_to_topics_pillow.dart';
import 'package:animation_types/pages/topics_to_story_animation_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                title: Text("Scroll Physics"),
                backgroundColor: Colors.lightBlue,
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopPillowAnimationPage(),
                    ),
                  );
                },
                child: Text("Shop Pillow Animation"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopPillowCircleRound(),
                    ),
                  );
                },
                child: Text("Shop Pillow Animation2"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopToTopicsPillow(),
                    ),
                  );
                },
                child: Text("Shop To Topics Animation"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicsToStoryAnimationWidget(),
                    ),
                  );
                },
                child: Text("Topics To Story"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomHeroAnimation(),
                    ),
                  );
                },
                child: Text("ListView Hero Animation"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GridSmoothFantasticGrid(),
                    ),
                  );
                },
                child: Text("Grid 2D Animation"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MotionStyleGrid(),
                    ),
                  );
                },
                child: Text("Motion style grid"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MotionMotionControllersScreen(),
                    ),
                  );
                },
                child: Text("Grid Motion Controllers Screen"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GridZAxisScreen(),
                    ),
                  );
                },
                child: Text("Grid z-Axis Screen"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhysicsButtonPlayground(),
                    ),
                  );
                },
                child: Text("Button animation"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhysicsScaleDemo(),
                    ),
                  );
                },
                child: Text("Button animation screen 2"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListviewAnimationsScreen(),
                    ),
                  );
                },
                child: Text("Listview Animations"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumPageViewScreen(),
                    ),
                  );
                },
                child: Text("PageView animation"),
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumPageViewScreen2(),
                    ),
                  );
                },
                child: Text("PageView animation2"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerticalParallaxPageView(),
                    ),
                  );
                },
                child: Text("PageView animation3"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WavePageViewScreen(),
                    ),
                  );
                },
                child: Text("PageView animation4"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZoomFadePageViewScreen(),
                    ),
                  );
                },
                child: Text("PageView animation5"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CurvedCarouselPageView(),
                    ),
                  );
                },
                child: Text("PageView animation6"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhysicsTabsWithSliders(),
                    ),
                  );
                },
                child: Text("TAB EXAMPLE 1"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhysicsTabsLab(),
                    ),
                  );
                },
                child: Text("TAB EXAMPLE 2"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
