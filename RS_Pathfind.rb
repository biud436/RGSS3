#==============================================================================
# Name : Pathfind
# Author : Yoji Ojima (KADOKAWA, RPG Maker MV)
# Date : 2019.03.30
# Version : 1.0.0
# Usage :
#
# 이동 루트의 설정에서 다음 스크립트를 호출하세요.
#   pathfind(x, y)
#   pathfind_ev(event_id)
# 
# 탐색 깊이를 변경하려면 다음 코드를 스크립트 호출로 호출해주세요.
#
#   Pathfind.limit = 15
#
#===============================================================================
$imported = {} if $imported.nil?
$imported["RS_Pathfind"] = true

#===============================================================================
# 설정
#===============================================================================
module Pathfind

  # 최대 탐색 깊이입니다.
  # 이 값보다 크게 하면 탐색 범위가 넓어집니다.
  # 하지만 범위 내에 타겟이 없을 경우 렉이 심해지게 됩니다.
  @@search_limit = 15
  
  # 스크립트 호출로 값을 탐색 깊이 값을 변경할 수 있습니다.
  def self.limit=(val)
    @@search_limit = val
  end
  def self.limit
    @@search_limit
  end  
end

#===============================================================================
# Game_Map
#===============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * delta_x
  #--------------------------------------------------------------------------
  def delta_x(x1, x2)
    result = x1 - x2
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result        
  end
  #--------------------------------------------------------------------------
  # * delta_y
  #--------------------------------------------------------------------------  
  def delta_y(y1, y2)
    result = y1 - y2
    if $game_map.loop_vertical? && result.abs > ($game_map.height / 2)
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result        
  end
  #--------------------------------------------------------------------------
  # * distance
  #--------------------------------------------------------------------------   
  def distance(x1, y1, x2, y2)
    delta_x(x1, x2).abs + delta_y(y1, y2).abs
  end
end
#===============================================================================
# Game_Character
#===============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # * 패스 파인딩
  # RPG Maker MV의 findDirectionTo(goalX, goalY)를 그대로 루비로 옮김
  # @author Yoji Ojima (KADOKAWA, RPG Maker MV)
  # @param {Integer} goal_x
  # @param {Integer} goal_y
  # @return {Integer} direction
  #--------------------------------------------------------------------------
  def find_direction_to(goal_x, goal_y)
    search_limit = Pathfind.limit
    map_width = $game_map.width
    node_list = []
    open_list = []
    closed_list = []
    start = {}
    best = start
    
    return 0 if @x == goal_x and @y == goal_y
    
    start[:parent] = nil
    start[:x] = @x
    start[:y] = @y
    
    # F = G + H
    # G = 시작점으로부터 목표 타일까지의 이동 비용; 생성된 경로 (장애물 피하는 경로)
    # 대각선 방향은 0, 수평은 수직은 1
    # H = 시작점으로부터 목표 타일까지의 이동 비용 (장애물 무시)
    # 대각선 방향을 무시하고 수평, 수직 이동 비용만 계산 1
    start[:g] = 0
    
    start[:f] = $game_map.distance(start[:x], start[:y], goal_x, goal_y)
    
    # 시작점을 열린 목록에 추가한다.    
    node_list.push(start)
    open_list.push(start[:y] * map_width + start[:x])
    
    while node_list.size > 0
      
      base_index = 0
      for i in (0...node_list.size)
        # F 비용 값이 가장 작은 노드를 찾는다.
        if node_list[i][:f] < node_list[base_index][:f]
          base_index = i
        end
      end
      
      # 현재 기준 노드를 설정한다.
      current = node_list[base_index]
      x1 = current[:x]
      y1 = current[:y]
      pos1 = y1 * map_width + x1
      g1 = current[:g]
      
      # F 비용이 가장 작은 노드를 열린 목록에서 빼고 닫힌 목록에 추가한다.
      node_list.delete_at(base_index)
      open_list.delete_at(open_list.index(pos1))
      closed_list.push(pos1)
      
      # 현재 노드가 목적지라면 베스트이므로 빠져나간다.
      if current[:x] == goal_x and current[:y] == goal_y
        best = current
        break
      end
      
      # g 비용이 12보다 커지면 최적화 문제로 탐색하지 않는다
      next if g1 >= search_limit
      
      # 인접한 4개의 타일을 열린 목록에 추가한다.
      for j in (0...4)
        direction = 2 + j * 2
        x2 = $game_map.round_x_with_direction(x1, direction)
        y2 = $game_map.round_y_with_direction(y1, direction)
        pos2 = y2 * map_width + x2
        
        # 닫힌 목록에 이미 있으면 무시한다.
        next if closed_list.include?(pos2)
        # 지나갈 수 없는 경우 무시한다.
        next if !$game_map.passable?(x1, y1, direction)
        
        # g 비용을 1 늘린다 (이동 했다고 가정)
        g2 = g1 + 1
        # 열린 목록에서 해당 노드의 인덱스 값을 찾는다 (int or nil)
        index2 = open_list.index(pos2) || -1
        
        # 노드를 찾을 수 없었거나, 새로운 찾은 노드의 이동 비용이 작을 경우
        if (index2 < 0) or (g2 < node_list[index2][:g])
          neighbor = {}
          if index2 >= 0
            # 이미 열린 목록에 있는 노드를 선택한다.
            neighbor = node_list[index2]
          else
            # 열린 목록에 방금 찾은 인접 타일을 추가한다.
            neighbor = {}
            node_list.push(neighbor)
            open_list.push(pos2)
          end
          
          # 새로 찾은 인접 노드의 부모가 이전 타일로 설정된다.
          neighbor[:parent] = current
          
          # 인접 타일의 F 비용이 계산된다.
          neighbor[:x] = x2
          neighbor[:y] = y2
          neighbor[:g] = g2
          # F값 = 이동 비용 + 장애물을 무시한 실제 거리
          neighbor[:f] = g2 + $game_map.distance(x2, y2, goal_x, goal_y)
          
          # best가 nil이거나, 인접 타일의 실제 거리 값이 더 짧으면
          if best.nil? or (neighbor[:f] - neighbor[:g]) < (best[:f] - best[:g])
            # 인접 타일을 베스트 노드로 설정
            best = neighbor
          end
        end
      end
    end
    
    # 최단 거리 노드 값을 가져온다
    node = best
    
    # 노드의 부모 노드로 거슬러 올라간다 (딱 한 칸만 거슬러 올라간다)
    while node[:parent] and node[:parent] != start
      node = node[:parent] 
    end
    
    # 거리 차 계산
    delta_x1 = $game_map.delta_x(node[:x], start[:x])
    delta_y1 = $game_map.delta_y(node[:y], start[:y])
    
    # 최단 거리 노드가 아래 쪽에 있다.
    if delta_y1 > 0
      return 2     
    # 최단 거리 노드가 왼쪽에 있다
    elsif delta_x1 < 0
      return 4
    # 최단 거리 노드가 오른쪽 쪽에 있다.
    elsif delta_x1 > 0
      return 6
    # 최단 거리 노드가 위 쪽에 있다.
    elsif delta_y1 < 0
      return 8
    end
    
    # 그래도 찾지 못했다면, 장애물을 고려하지 않는 거리가 가장 가까운 곳으로 이동한다.
    delta_x2 = distance_x_from(goal_x)
    delta_y2 = distance_y_from(goal_y)
    if delta_x2.abs > delta_y2.abs
      return delta_x2 > 0 ? 4 : 6
    elsif delta_y2 != 0
      return delta_y2 > 0 ? 8 : 2
    end
    
    # 이동 불가능
    return 0      
      
  end
  #--------------------------------------------------------------------------
  # * pathfind
  #--------------------------------------------------------------------------   
  def pathfind(x, y)
    dir = find_direction_to(x, y)
    move_straight(dir) if dir > 0
  end
  #--------------------------------------------------------------------------
  # * pathfind
  #--------------------------------------------------------------------------    
  def pathfind_v(target)
    dx = target.x
    dy = target.y
    dr = target.direction
    if $game_map.passable?(dx, dy, dr)
      dir = find_direction_to(dx, dy)
      move_straight(dir) if dir > 0
    end
  end
  #--------------------------------------------------------------------------
  # * pathfind_ev
  #--------------------------------------------------------------------------   
  def pathfind_ev(event_id)
    event = $game_map.events[event_id]
    return if not event
    tx = event.x
    ty = event.y
    dir = find_direction_to(tx, ty)
    move_straight(dir) if dir > 0
  end 
end
