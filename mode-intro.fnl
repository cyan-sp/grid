(local fennel (require :lib.fennel))
(import-macros {: incf} :sample-macros)
(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local unpack (or table.unpack _G.unpack))

(local Square (Object:extend))

(fn Square.new [self id x y]
  (set self.id id)
  (set self.x x)
  (set self.y y)
  (set self.active false))

(fn Square.draw-tile [self]
  ;; (if (not (. self :active))
  ;;     (love.graphics.setColor 1 0 0))
  (love.graphics.setColor 1 1 1)
  (love.graphics.rectangle "line" self.x self.y 100 100)
  (love.graphics.print self.id self.x self.y)
  ;; (love.graphics.setColor 1 0 0)
  ;; (love.graphics.circle "fill" (+ self.x 50) (+ self.y 50) 3)
)

(fn Square.draw-cursor [self]
  (love.graphics.setColor 0 1 1)
  (love.graphics.rectangle "line" self.x self.y 100 100)
  (love.graphics.setColor 1 0 0)
  (love.graphics.circle "fill" (+ self.x 50) (+ self.y 50) 3)
  (love.graphics.print (.. "x:" self.x "y:" self.y) (+ self.x 50) (+ self.y 50))
  (print (.. "active : " self.id " x:" self.x "y:" self.y))
  ;; (print (love.graphics.print (.. "x:" self.x "y:" self.y) (+ self.x 50) (+ self.y 50)))
  ;; (love.graphics.line self.x self.y 100 100)
  )

(fn Square.activate [self]
  (tset self :active true))

(var game-squares [])
(var cursor-position 4)

(local Table (Object:extend))

(fn Table.new [self]
  (set self.squares []))

(fn Table.table-make [self width height]
  (local squares [])
  (var curr 0)
  (for [j 1 height]
    (for [i 1 width]
      (set curr (+ 1 curr))
      (local square (Square curr (* 100 i) (* 100 j)))
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
             (table:table-make 2 2)
             ;; (Square.activate (. game-squares 1))
             ;; (Square.activate (. game-squares 2))
             
             )

 :draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (draw-squares)
         (Square.draw-cursor (. game-squares cursor-position)))

 :keypressed (fn keypressed [key set-mode]
               (when (= key "escape")
                 (love.event.quit))
               (when (= key "down")
                 (set cursor-position 1))
)}
