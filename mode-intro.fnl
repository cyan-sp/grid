(local fennel (require :lib.fennel))
(import-macros {: incf} :sample-macros)
(local Object (require :lib.classic))
(local unpack (or table.unpack _G.unpack))

(local Tile (Object:extend))

(local GRID-SIZE 70)

(var cursor-id 2)

(var apple-id 1)

(var game-tiles [])

(fn Tile.new [self id x y]
  (set self.id id)
  (set self.x x)
  (set self.y y))

(fn Tile.draw-tile [self]
  (love.graphics.setColor 1 1 1)
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (love.graphics.print self.id self.x self.y))

(fn Tile.draw-cursor [self]
  (love.graphics.setFont (love.graphics.newFont 19))
  (love.graphics.setColor 0 1 1)
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (local font (love.graphics.getFont))
  (local text-height (font:getHeight))
  (love.graphics.printf "@" self.x (+ self.y (/ GRID-SIZE 2) (/ text-height -2)) GRID-SIZE "center"))

(fn Tile.draw-apple [self]
  (love.graphics.setColor 1 0 0)
  (love.graphics.circle "fill" (+ self.x (/ GRID-SIZE  2)) (+ self.y (/ GRID-SIZE  2)) 3)
  (if (= (. self :id) cursor-id)
      (set apple-id (math.random 1 25))))

(local snake-id-tiles [])

(fn Tile.step [self direction]
  (let [[dx dy] (case direction
                  :up [0 (- GRID-SIZE)]
                  :down [0 GRID-SIZE]
                  :left [(- GRID-SIZE) 0]
                  :right [GRID-SIZE 0])]
    (each [_ tile (ipairs game-tiles)]
      (when (and (= (. tile :x) (+ self.x dx))
                 (= (. tile :y) (+ self.y dy)))
        (set cursor-id (. tile :id))))))

(local Table (Object:extend))

(fn Table.new [self]
  (set self.tiles []))

(fn Table.table-make [self width height]
  (local tiles [])
  (var curr 0)
  (for [j 1 height]
    (for [i 1 width]
      (set curr (+ 1 curr))
      (local tile (Tile curr (* GRID-SIZE i) (* GRID-SIZE j)))
      (table.insert tiles tile)))
  (set self.tiles tiles)
  (set game-tiles tiles)
  (print (.. :tiles (fennel.view tiles)))
  (local x-values (icollect [_ tile (ipairs tiles)] tile.x))
  (local y-values (icollect [_ tile (ipairs tiles)] tile.y))
  (local max-x (math.max (unpack x-values)))
  (local max-y (math.max (unpack y-values)))
  (print (.. "Max X: " max-x " Max Y: " max-y)))

(fn draw-tiles []
  (each [_ tile (ipairs game-tiles)]
    (tile:draw-tile)))

{:activate (fn activate []
             (local table (Table))
             (table:table-make 5 5)
             (Tile.step (. game-tiles cursor-id) :right)
             (Tile.step (. game-tiles cursor-id) :right)
             )

 :draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (draw-tiles)
         (Tile.draw-cursor (. game-tiles cursor-id))
         (Tile.draw-apple (. game-tiles apple-id))
)

 :keypressed (fn keypressed [key set-mode]
               (when (= key "escape")
                 (love.event.quit))
               (when (= key "down")
                 (Tile.step (. game-tiles cursor-id) :down))
               (when (= key "up")
                 (Tile.step (. game-tiles cursor-id) :up))
               (when (= key "right")
                 (Tile.step (. game-tiles cursor-id) :right))
               (when (= key "left")
                 (Tile.step (. game-tiles cursor-id) :left)))}
