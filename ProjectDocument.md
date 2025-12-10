# The title of your game #

## Summary ##

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

- Vignette Shader code from imakeshaders on Godot Shaders website [here](https://godotshaders.com/shader/vignette-2/)
- Animation Tree setup tutorial from YouTube channel [Chris' Tutorials](https://www.youtube.com/watch?v=WrMORzl3g1U)
- Interactable objects in godot.[Queble](https://www.youtube.com/watch?v=pQINWFKc9_k)

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```

For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item git. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.

# Main Roles #

- Animation and Visuals (Jordan)
- Others, add roles here!

## Animation and Visuals (Jordan, Jordanjt4 on Github)
Explain why I switched roles.

### Assets - I drew and animated all assets except TileMap and UI elements.

![Jordan's Assets](<ProjectDocument Images/jordan-assets.jpeg>)

This includes:
- MC Warden Gramsey (running in all directions, idle, hurt, death)
- Fruits (attack, hurt, idle, death):
  - Blueberry
  - Strawberry
  - Watermelon
  - Grape
  - Pomegranate
  - Grapes and Single Grapes
  - Cornucopia Final Boss
- Peach Tree with animation
- Main menu background
- Skill Tree background and peaches
- GMO! Logo
- the two types of seed bullets

### Visual Style
![GMO Logi](<gmo/assets/Main Menu/gmo_logo.png>)
We wanted a vibrant, cute, and fun 2D pixel style game that emphasizes visual charm while still making it intense. Warden is a chef who accidentally made sentient fruit, so I wanted his design to reflect this crazy chef who would probably blow up a kitchen given the chance (crazy eyes and dramatic coat). The fruits are all designed to look fierce while maintaining likeability, like Mario's enemies. I tried to emphasize this in their movements, facial expressions, and how they are posed in the logo.
We chose for the peach tree to be animated, to draw attention to it and remind the player that it is a crucial structure to defend.

### Animation
All animated assets were animated and previewed in my drawing program. When assetes were approved, I exported them as sprite sheets and uploaded them into Godot.
I set up animation players for all animated assets. All were created by setting the sprite sheed for that animation, adjusting h and v frames, and setting frames according to custom playback speed.
Afterwards, I set up an animation tree and drew the animation state machine. I set conditions and applicable transition constraints for each transition.

All assets have an [AnimationManagerComponent](https://github.com/RashmitShrestha/gmo/blob/4e3038445af44eb82a12f019032c73c315dc8e17/gmo/scripts/components/character_components/player_components/player_animation_manager_component.gd#L1C1-L19C78). It separates gameplay logic from animation tree system. For every character:
- Idle animation alawys plays by default
- If parent is damaged, plays hurt animation once (per damage). Since it takes a second to play the whole animation, I set it so the animation has to finish playing before playing again, otherwise it wouldn't show because the enemy is taking damage in rapid succession. 
- If enemy is attacking, plays attack animation once (per attack).

This AnimationManagerComponent makes it easy to just insert boolean updates in the main enemy scripts, and the animation will take care of itself.

Warden has a special [BlendSpace2D](https://github.com/RashmitShrestha/gmo/commit/9097a6e30d26481a5a1949c2a3c7678e9880c04e#diff-9632bb3e417d0906704663b39dbbedd9c3fd22e935f9eac465456d5ed93eaad8R1), which helps automatically determine the correct running animation to play depending on which way the character is facing.

[Death animations](https://github.com/RashmitShrestha/gmo/blob/4e3038445af44eb82a12f019032c73c315dc8e17/gmo/scripts/characters/fruit.gd#L122C1-L131C20) are played manually from the AnimationPlayer. I also had to make sure the animation fully plays before the actual death function begins, to ensure the player can visually see the animation play before the game officially considers the enemy death and turns off visibility.

# Sub-Roles 

- Game Feel (Jordan)
- Others, add roles here!

## Game Feel

I focused on visual screen feedback with shaders.
The [health bar shakes](https://github.com/RashmitShrestha/gmo/blob/e5c976f20b69b999fd87a8b62518a438c27f42dc/gmo/scripts/ui/health_bar.gd#L44C1-L62C3) when player takes damage, making damage more impactful and noticable. 
When player health is below 20%, a [red vignette](https://github.com/RashmitShrestha/gmo/blob/e5c976f20b69b999fd87a8b62518a438c27f42dc/gmo/scripts/ui/health_bar.gd#L65C1-L72C53) is applied on screan, notifying the player that they are low health and should take more caution. 
The actual vignette shader code is from the Godot Shader website [here](https://godotshaders.com/shader/vignette-2/). I edited its opacity and strength depending on what the health is.
It was imperative that Warden had a quick and reactive damage indicator, so the animation player/tree was not enough. Also, I had only drawn a hurt animation for when he was idle, and I quickly realized this was not ideal because he had a bunch of different animations that he could be in when he gets hit. I used self modulate to quickly tint his original color by [red](https://github.com/RashmitShrestha/gmo/blob/e5c976f20b69b999fd87a8b62518a438c27f42dc/gmo/scripts/characters/warden.gd#L186C2-L188C42) no matter what state he was in, and he would always turn red upon impact.

I also introduced visual feedback in sprites as well. I drew unlocked, ready to unlock, and unlocked peaches for the skill tree menu, so the player can instantly see which nodes they can unlock by color alone.

## Other Contributions ##
