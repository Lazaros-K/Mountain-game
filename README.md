Added an abstact class "abstract_options" to create the method "open()" so we get rid of the warning. The "options_menu" class extends the "abstract_options".
Made the "player_level_gui" scene with the "heart_bar" and "score_counter" scene as children. We pass the character with export.
Made the "scene_uid" script with constants of type String containing the uid of each scene so we can use them in other scripts instead of using paths.
Also changed the score counter so that is counts actual tiles.
