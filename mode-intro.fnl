(local fennel (require :lib.fennel))
(import-macros {: incf} :sample-macros)
(local fennel (require :lib.fennel))
(local Object (require :lib.classic))

(local Square (Object:extend))

(fn Square.new [self id x y]
  (set self.id id)
  (set self.x x)
  (set self.y y)
  (set self.active false))

(fn Square.draw [self]
  (if (not (. self :active))
      (love.graphics.setColor 1 0 0))
  (love.graphics.rectangle "line" self.x self.y 100 100)
  (love.graphics.print self.id self.x self.y))

(fn Square.activate [self]
  (tset self :active true)
  ;; (print self)
  )

(var game-squares [])

(fn make-table [width height]
  (local squares [])
  (var curr 0)
  (for [i 1 width]
    (for [j 1 height]
      (set curr (+ 1 curr))
      (local square (Square curr (* 100 i) (* 100 j)))
      (table.insert squares square)))
  (set game-squares squares)
  (print (.. :squares (fennel.view squares)))
  ;; (print (.. :squares s))
  ;; (print (.. :active (. (. squares 1) 1)))
  )

(fn draw-squares []
  (each [_ square (ipairs game-squares)]
    (square:draw)))

{:activate (fn activate []
             (make-table 5 5)
             (Square.activate (. game-squares 1))
             (Square.activate (. game-squares 2)))

 :draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (draw-squares))

 :keypressed (fn keypressed [key set-mode]
               (when (= key "escape")
                 (love.event.quit)))}



