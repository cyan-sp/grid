(local fennel (require :lib.fennel))
(import-macros {: incf} :sample-macros)
(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local unpack (or table.unpack _G.unpack))

(local Square (Object:extend))

(local GRID-SIZE 70)

(fn Square.new [self id x y]
  (set self.id id)
  (set self.x x)
  (set self.y y)
  (set self.active true))

(fn Square.draw-tile [self]
  (love.graphics.setColor 1 1 1)
  (if (= (. self.active) false)      
      (love.graphics.setColor 1 0 0))
  
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (love.graphics.print self.id self.x self.y))

(fn Square.draw-cursor [self]
  (love.graphics.setFont (love.graphics.newFont 19))
  (love.graphics.setColor 0 1 1)
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (local font (love.graphics.getFont))
  (local text-height (font:getHeight))
  (love.graphics.printf "@" self.x (+ self.y (/ GRID-SIZE 2) (/ text-height -2)) GRID-SIZE "center"))

(var cursor-id 2)

(fn Square.desactivate [self]
  (tset self :active false))

(var game-squares [])

(fn Square.search [self direction]
  (let [cursor (. game-squares cursor-id)
        [dx dy] (case direction
                  :up [0 (- GRID-SIZE)]
                  :down [0 GRID-SIZE]
                  :left [(- GRID-SIZE) 0]
                  :right [GRID-SIZE 0])]
    (each [_ square (ipairs game-squares)]
      (when (and (= (. square :x) (+ (. cursor :x) dx))
                 (= (. square :y) (+ (. cursor :y) dy))
                 (= (. square :active) true))
        (set cursor-id (. square :id))))))

(local Table (Object:extend))

(fn Table.new [self]
  (set self.squares []))

(fn Table.table-make [self width height]
  (local squares [])
  (var curr 0)
  (for [j 1 height]
    (for [i 1 width]
      (set curr (+ 1 curr))
      (local square (Square curr (* GRID-SIZE i) (* GRID-SIZE j)))
      (table.insert squares square)))
  (set self.squares squares)
  (set game-squares squares)
  (print (.. :squares (fennel.view squares)))
  (local x-values (icollect [_ square (ipairs squares)] square.x))
  (local y-values (icollect [_ square (ipairs squares)] square.y))
  (local max-x (math.max (unpack x-values)))
  (local max-y (math.max (unpack y-values)))
  (print (.. "Max X: " max-x " Max Y: " max-y)))

(fn draw-squares []
  (each [_ square (ipairs game-squares)]
    (square:draw-tile)))

{:activate (fn activate []
             (local table (Table))
             (table:table-make 5 5)
             (Square.desactivate (. game-squares 1)))

 :draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (draw-squares)
         (Square.draw-cursor (. game-squares cursor-id)))

 :keypressed (fn keypressed [key set-mode]
               (when (= key "escape")
                 (love.event.quit))
               (when (= key "down")
                 (Square.search (. game-squares cursor-id) :down))
               (when (= key "up")
                 (Square.search (. game-squares cursor-id) :up))
               (when (= key "right")
                 (Square.search (. game-squares cursor-id) :right))
               (when (= key "left")
                 (Square.search (. game-squares cursor-id) :left)))}
