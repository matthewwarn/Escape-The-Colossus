using Godot;
using System;
using System.Diagnostics.CodeAnalysis;

public partial class player : CharacterBody2D
{
	public const float Speed = 100.0f;
	public const float JumpVelocity = -350.0f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	// References to child nodes
	private CoyoteTimer _coyoteTimer;
	private AnimatedSprite2D _sprite;

	public override void _Ready()
	{
		_coyoteTimer = (CoyoteTimer) GetNode<Timer>("CoyoteTimer");
		_sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
			velocity.Y += gravity * (float)delta;

		// Handle jump using coyote time.
		// When the player steps off a platform start a short timer
		// If the timer is running then the player can still jump even though they are not touching the ground.
		// imagine it like when a cartoon character steps off a cliff and doesn't notice for a moment.
		
		// Start the coyote time only if it has not already been used since the player left the ground.
		if (!IsOnFloor())
			_coyoteTimer.StartIfAvailable();
		
		// Reset the coyote timer when the player touches the ground so that it can be used again.
		if (IsOnFloor())
			_coyoteTimer.Reset();

		// Jump!
		if (Input.IsActionJustPressed("jump") && (IsOnFloor() || !_coyoteTimer.IsStopped()))
		{
			velocity.Y = JumpVelocity;
			// Once we have jumped we need to make sure coyote time cannot be used until the next time the player touches the ground.
			_coyoteTimer.Disable();
		}


		// Get the input direction and handle the movement/deceleration.
		Vector2 direction = Input.GetVector("move_left", "move_right", "ui_up", "ui_down");
		if (direction != Vector2.Zero)
		{
			velocity.X = direction.X * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
		}

		Velocity = velocity;
		MoveAndSlide();
		
		// Change sprite orientation when player direction changes.
		if (direction.X > 0)
			_sprite.FlipH = true;
		else if (direction.X < 0)
			_sprite.FlipH = false;
		
		// Play animations
		if (IsOnFloor())
		{
			if (direction.X == 0)
				_sprite.Play("Idle");
			else
				_sprite.Play("Movement");
		}
		else
		{
			_sprite.Play("Jump");
		}
	}
}
