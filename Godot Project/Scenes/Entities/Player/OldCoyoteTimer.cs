using Godot;
using System;

public partial class OldCoyoteTimer : Timer
{
	private bool Used = false;
	
	/// <summary>
	/// Start a timer to give the player a brief period they can air-jump in.
	/// If the Coyote Timer has already been used since the last time the player
	/// touched the ground then the timer will not start.
	/// </summary>
	public void StartIfAvailable()
	{
		if (Used)
			return;
		Start();
		Used = true;
	}

	/// <summary>
	/// Call this when the player touches the ground after jumping.
	/// </summary>
	public void Reset()
	{
		Used = false;
		Stop();
	}

	/// <summary>
	/// Call this when the player jumps so that they don't accidentally get double jump.
	/// </summary>
	public void Disable()
	{
		Used = true;
		Stop();
	}
}
