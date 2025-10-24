(local fennel (require :lib.fennel))
(import-macros {: incf} :sample-macros)
(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local unpack (or table.unpack _G.unpack))

(local Square (Object:extend))

(local GRID-SIZE 100)

(fn Square.new [self id x y]
  (set self.id id)
  (set self.x x)
  (set self.y y)
  (set self.active false))

(fn Square.draw-tile [self]
  (love.graphics.setColor 1 1 1)
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (love.graphics.print self.id self.x self.y))

(fn Square.draw-cursor [self]
  (love.graphics.setColor 0 1 1)
  (love.graphics.rectangle "line" self.x self.y GRID-SIZE GRID-SIZE)
  (love.graphics.circle "fill" (+ self.x (/ GRID-SIZE 2)) (+ self.y (/ GRID-SIZE 2)) 3)
  (love.graphics.print (.. "x:" self.x "y:" self.y) (+ self.x 50) (+ self.y 50)))

(var cursor-id 2)

(fn Square.activate [self]
  (tset self :active true))

(var game-squares [])

(fn Square.search-below [self]
  (let [cursor (. game-squares cursor-id)]
    (each [_ square (ipairs game-squares)]
      (when (and (= (. square :y) (+ GRID-SIZE (. cursor :y)))
                 (= (. square :x) (. cursor :x)))
        (set cursor-id (. square :id))))))

(fn Square.search-above [self]
  (let [cursor (. game-squares cursor-id)]
    (each [_ square (ipairs game-squares)]
      (when (and (= (. square :y) (- (. cursor :y) GRID-SIZE))
                 (= (. square :x) (. cursor :x)))
        (set cursor-id (. square :id))))))

(fn Square.search-right [self]
  (let [cursor (. game-squares cursor-id)]
    (each [_ square (ipairs game-squares)]
      (when (and (= (. square :x) (+ GRID-SIZE (. cursor :x)))
                 (= (. square :y) (. cursor :y)))
        (set cursor-id (. square :id))))))

(fn Square.search-left [self]
  (let [cursor (. game-squares cursor-id)]
    (each [_ square (ipairs game-squares)]
      (when (and (= (. square :x) (- (. cursor :x) GRID-SIZE))
                 (= (. square :y) (. cursor :y)))
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
             (table:table-make 3 3))

 :draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (draw-squares)
         (Square.draw-cursor (. game-squares cursor-id)))

 :keypressed (fn keypressed [key set-mode]
               (when (= key "escape")
                 (love.event.quit))
               (when (= key "down")
                 (Square.search-below (. game-squares cursor-id)))
               (when (= key "up")
                 (Square.search-above (. game-squares cursor-id)))
               (when (= key "right")
                 (Square.search-right (. game-squares cursor-id)))
               (when (= key "left")
                 (Square.search-left (. game-squares cursor-id))))}

