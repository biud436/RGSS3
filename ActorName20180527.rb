class Window_Status < Window_Selectable
  def draw_actor_name(actor, x, y, width = 112)
    change_color(hp_color(actor))
    width = text_size(actor.name).width * 2
    draw_text(x, y, width, line_height, actor.name)
  end
end