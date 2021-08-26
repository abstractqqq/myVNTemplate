# Godette VN, A Visual Novel Framework for Godot Users

In the folder /GodetteVN/ , you can find sample projects to run.

Before you run your own sample scene, make sure your character is created via the 
actor editor and saved as a scene. Moreover, you have to register your characters
in characterManager.gd (this file can be found in the singleton folder.) 

There are 3 core components in this framework.
1. An actor editor (WIP, mostly stable for written functions) 
2. A script editor (WIP, mostly stable for written functions)
3. A core dialog system (basically a json interpreter, mostly stable)  

Core dialog system can be found in /scenes/fundamental/details/generalDialog.gd
To see how spritesheet animation is integrated into VNs, go to 
/GodetteVN/Characters/gt.tscn to check it out.

For basic dialog for RPG games, then [Dialogic](https://github.com/coppolaemilio/dialogic) might be a better addon than this, 
because this framework is solely focused on the making of Visual/Graphic Novel. Renpy is also a good 
alternative if your game doesn't include advanced features or complicated minigames.

Transition system is integrated from eh-jogos's project. You can find it [here](https://github.com/eh-jogos/eh_Transitions)

Video Showcases:

[Parallax and Sprite Sheet Animation](https://www.youtube.com/watch?v=sG7tDFsk4HE)

[General Gameplay](https://www.youtube.com/watch?v=uODpTQz6Vu0&t=43s)

Other examples like timed choice, investigation scene, can be found in the folder /GodetteVN/

Projects done with this template:
[My O2A2 entry](https://tqqq.itch.io/o2a2-elegy-of-a-songbird)

------------------------------------------------------------------------------------------------------------------------------

A link to the [documentation](https://drive.google.com/file/d/1GnNqZsEiuScddbIXL5IWVSM-kF7ECFD-/view?usp=sharing)

If you're too a programmer, you might be interested in the [design doc](https://docs.google.com/document/d/1_j8YX7iYI9FBYTwUS_dhHKJdJcFYeaHjLQ8eWzhaA2s/edit?usp=sharing)

If you want to contact me:
Discord: T.Q#8863