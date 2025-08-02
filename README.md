# Arcturus Autonomy Onboarding Lab
## Intro

**Welcome to Arcturus Autonomy!** This is an onboarding lab whose goal is to familiarize you with the Arcturus Autonomy stack, get you acquainted with ROS, and help you learn how to perform tasks that you may need to do many times during the competition season, when you are working on competition tasks, as well as teach you how to work around various types of problems that you will encounter during that time.

## Part 1

## Part 2

Now that you learned how to use the YOLO detections and a PID controller to pass through pairs of buoys, let's see how we can make that more robust by using our perception & navigation stack as a whole. This will serve as the foundation for when you are working on competition tasks during the year, where we want to get the most out of our system's capabilities to achieve maximum performance.

### Local Map

Cameras only give us information about the direction in which a buoy is detected, and maybe the bounding box area can help us estimate the size of it assuming all buoys have the same size. However, we have a source of depth information: the LiDAR. Since we have the bounding boxes that are published by `yolov8_node`, and the filtered point cloud from `point_cloud_filter`, we can use both to get obstacle detetions in 3D space, in the `base_link` (the robot's) frame.

That is being done by `bbox_project_pcloud`, which subscribes to the image topic of the camera (in simulation it's `/wamv/sensors/cameras/front_left_camera_sensor/image_raw`), the `bounding_boxes` topic with the YOLO detections, the LiDAR filtered point cloud `point_cloud/filtered`, and the camera info topic (in sim: `/wamv/sensors/cameras/front_left_camera_sensor/camera_info`), which provides the camera parameters needed to project points from camera optical frame (3D) to the image plane (2D).

`bbox_project_pcloud` publishes the `obstacle_map/local` topic, which is of type [`ObstacleMap`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/msg/ObstacleMap.msg), and contains the set of detected obstacles in the `base_link` (or, in sim, `wamv/wamv/base_link`) frame. That's the local map we are going to use first.

[`ObstacleMap`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/msg/ObstacleMap.msg) is a message type that's being used both for the local and the global map, and thus some fields might be empty (the local or global ones) depending on the use case, and it's structured as follows:
* `header` contains the global frame id (`map` usually) and stamp of the detections (only in the global map)
* `local_header` contains the local frame id and stamp of the detections (both in the global and the local map)
* `obstacles` is a list of objects/messages of type [`Obstacle`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/msg/Obstacle.msg), which has the following fields:
  * `id`: the obstacle id (only useful when obstacles are being tracked, in the global map)
  * `label`: the YOLOv8 label given to the bounding box associated with the obstacle -> **the label for red is 11 and green is 17**, you are going to need that later
  * `local_point`/`global_point`: the centroid of the object's detected point cloud, in the local/global frame (`map`/`base_link` respectively)
  * stacle
  * `local_chull`/`global_chull`: the convex hull of the, flattened to 2D, object's detected point cloud, in the local/global frame
  * `polygon_area`: the area of the convex hull
  * `bbox_min`/`bbox_max`: the points with the minimum/maximum x,y, and z (individually), of the object's point cloud, in the local frame
  * `global_bbox_min`/`global_bbox_max`: the points with the minimum/maximum x,y, and z (individually), of the object's point cloud, in the global frame

### Going through a pair of buoys using the local map

So, the goal of this task is the same as part 1 of the lab, but you are going to use the local map ([`ObstacleMap`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/msg/ObstacleMap.msg)) published in the `obstacle_map/local` topic, instead of the YOLO bounding boxes, to navigate to that pair.

The way this is going to be done is the following:
1. You need to subscribe to the `obstacle_map/local` topic, and each time you get a new local map, identify the pair of buoys you want to go through (***hint:** just pick the closest ones of red and green color*)
2. Now you have the positions of the buoys in the robot's frame, you want to navigate through them, so just aim for the midpoint
3. For the control loop, in the previous part you used a PID controller that just had the error be distance of the bounding box from the center of the image, but now you have target coordinate's in the robot's frame, in 2D space (ignore the z component). You are still going to use a PID controller (or many?), but in a different way this time.

#### Editing and running the code
TODO

#### Steps to success

Here's a couple of things you need to think through before you start coding:
* **Take it one step at a time:** buoy picking, waypoint computation, error computation, PID controller setup & fine-tuning.
* Which fields are you going to use to get the detected buoys positions? check the message description above
* This time your goal is to reach a certain position with the robot, but that position is in the robot's frame. That actually makes things quite easy for you, because when your robot is to the left of the buoy, the buoy is to the right of the robot, and you want to go right, so there is a direct correlation of the x component of the buoy and the x velocity you want to have. Same for y. How are you going to make a PID controller that takes into account those errors to go where you want it (watch out for the signs, think of what the PID controller will do when x/y is positive/negative)?
* Does the robot angle play a role in this task? You can get creative, think about the trajectory the robot to take in the case where: a) you don't set an angle error to the PID, b) you set the target angle to be dynamically set to the direction from the robot to the midpoint, or c) you set the target angle to be the robot facing perpendicular to the buoy pair (forwards) when it reaches it. Or you can do something different.
* What should you do when you only see one of the buoys? The controller will definitely not be as accurate as when you see both of them, but maybe you can make some assumptions about the buoys' relative position to keep the robot moving in the correct direction (and recover, if it's gone too far right or left).

You don't have to worry about termination conditions for now, just get the control loop working first (you can just make the controller do nothing, or send a stop command, when it doesn't see any of the two buoys).

The end result should look like this:

TODO: add a video of the end result in RViz after coding the solution

#### Debugging tips:
* Use [RViz markers](http://wiki.ros.org/rviz/DisplayTypes/Marker) to your advantage. They can represent arbitrary points (or even directions, if it's an arrow marker) in space, so when the controller seems to not be working properly, verify that you are setting the correct target and picking the correct buoys. Whenever you are setting a single marker (or have a predefined set of markers for certain points that dynamically change, like a waypoint for example) you can use a [Marker](https://docs.ros2.org/galactic/api/visualization_msgs/msg/Marker.html) message, otherwise (when you have an arbitrary number of markers) use a [MarkerArray](https://docs.ros2.org/galactic/api/visualization_msgs/msg/MarkerArray.html). In the latter case, pay attention to setting a different id to each marker, and to clearing all the markers before sending new ones (by setting a `DELETALL` action to the first marker of the message, or sending a separate marker array with a single marker with that action before the new array of markers, or you can set a lifetime to the markers which might be preferrable). TODO: Add an example marker/marker array publishing code to not have to debug markers.
* Check the signs of the PID controller (error sign vs effort sign in various cases), and start with just the $K_p$ coefficient ($K_i$ and $K_d$ set to 0), then you can try making it smoother by adding a $K_d$ coefficient and if there's a steady state offset (robot constantly undercorrecting) you can add a small $K_i$ coefficient.

### Arcturus Localization, Mapping, and Navigation Stack
TODO: Add a thorough description and explanation of our stack and what they can use/how they can interface with it to complete tasks.

### Going through a pair of buoys using the navigation stack

Now that you know how to use the `ObstacleMap` message and deal with buoys' positions in 2D, let's use the Arcturus localization, mapping, and navigation stack to achieve better results. Notably:
1. You will subscribe to the `obstacle_map/global` topic, which is the same type as `obstacle_map/local` ([`ObstacleMap`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/msg/ObstacleMap.msg)), but it now has the fields related to the buoys' position in the global frame populated as well. So, now, instead of using the local frame coordinates, you are using global ones.
2. In order to pick the buoys and navigate to them, you also need to know the robot's position. You can do that using the provided `self.get_robot_pose()` function of the base action server class (which your node inherits from), and it will give you an **(x,y,heading)** tuple with the robot's position and orientation in the global frame. 
3. Now that you have the robot's and detected buoys' positions, how are you going to pick the buoys you want to go through? You need to make some assumptions (***hint:** in front of the robot, closest to it, right green, left red*)
4. Using the picked buoys' positions, you can easily compute the waypoint position like you did in the last part (just x,y position, no need to compute the orientation here). Then, you have all the information you need to send to the A* planner node, so you just make a `follow_path` service request (of action type [`FollowPath`](https://github.com/ArcturusNavigation/all_seaing_vehicle/blob/main/all_seaing_interfaces/action/FollowPath.action)) using that information and setting the parameters appropriately. TODO: Add an example A* service request code to not have to debug that

For now, you don't have to worry about terminations conditions and transitions between buoys, that'll be the next (and last) part of the lab.


The end result should look like this:

TODO: add a video of the end result in RViz after coding the solution

#### Editing and running the code
TODO

#### Steps to success

* This time you don't have a control loop, like when you did the PID controller. The control loop is handled by the PID controller node, so you just send the waypoint once (or maybe more than once if the goal failed for some reason, then you do the same computation again and send a new waypoint).
* To check if a buoy is in front of the robot, there are two ways to do it. You now have both the local and global coordinates of the buoys detected, so you can use either of those, but one of them might be harder, so think about it before starting to code (you also have the robot's position **and orientation**). Think about the robot's coordinate frame, and keep in mind that, in that frame (not the global frame), **x is forwards**.

#### Debugging tips:
* As before, use informative markers, and publish info messages with the action server's status and maybe some computation/selection steps.

### Transitioning between pairs
In the competition you don't have just a single pair of buoys, but instead need to go through a path with many pairs of green and red buoys. Therefore, although the idea is the same as in the previous sections, you need to detect when you've passed one pair of buoys and need to compute a new waypoint corresponding to the next pair (if it exists). You'll change the code you wrote in the previous section to handle that.

When you don't see any more buoy pairs in front, send a stop command. When that's the case for more than 5 seconds, send a goal success response to the task server.

The end result should look like this:

TODO: add a video of the end result in RViz after coding the solution

#### Editing and running the code
TODO

#### Steps to success
* You know which buoy is left and which buoy is right from when you compute them. Given that information, and assuming that you have a function that tells you, given three points in order, whether they form a clockwise or a counterclockwise angle, how can you compute whether the robot has passed the selected buoy pair? That function is given in the skeleton code of the last section.

#### Debugging tips:
* Markers and info messages are your friends in case of uncertainty, don't be afraid to use them. Computation/selection steps and action server status is where most of the confusion happens.

If you are done, **congratulations on completing the Arcturus Autonomy Onboarding Lab!** You may talk to one of the leads (Panos or Brendon) about picking up a task and getting to actual work.