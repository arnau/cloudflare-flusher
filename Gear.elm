module Gear exposing (gear)

import Svg exposing (..)
import Svg.Attributes exposing (..)

gear name =
  svg [ version "1.1"
      , id name
      , x "0px"
      , y "0px"
      , width "32px"
      , height "32px"
      , viewBox "0 0 32 32"
      ]
      [ g []
          [ rect [ fill "none"
                 , width "32"
                 , height "32"
                 ] []
          ]
      , Svg.path [ d "m 28,24 v -2.001 h -1.663 c -0.063,-0.212 -0.145,-0.413 -0.245,-0.606 l 1.187,-1.187 -1.416,-1.415 -1.165,1.166 c -0.22,-0.123 -0.452,-0.221 -0.697,-0.294 V 18 h -2 v 1.662 c -0.229,0.068 -0.446,0.158 -0.652,0.27 l -1.141,-1.14 -1.415,1.415 1.14,1.14 C 19.821,21.554 19.731,21.771 19.662,22 H 18 v 2 h 1.662 c 0.073,0.246 0.172,0.479 0.295,0.698 l -1.165,1.163 1.413,1.416 1.188,-1.187 c 0.192,0.101 0.394,0.182 0.605,0.245 V 28 H 24 v -1.665 c 0.229,-0.068 0.445,-0.158 0.651,-0.27 l 1.212,1.212 1.414,-1.416 -1.212,-1.21 C 26.176,24.445 26.266,24.228 26.335,24 H 28 z m -5.001,0.499 c -0.829,-0.002 -1.498,-0.671 -1.501,-1.5 0.003,-0.829 0.672,-1.498 1.501,-1.501 0.829,0.003 1.498,0.672 1.5,1.501 -0.002,0.829 -0.671,1.498 -1.5,1.5 z M 14,23 c 0,-4.973 4.027,-9 9,-9 l 0,0 c 4.971,0 8.998,4.027 9,9 l 0,0 c -0.002,4.971 -4.029,8.998 -9,9 l 0,0 c -4.973,-0.002 -9,-4.029 -9,-9 l 0,0 z m 2.115,0 c 0.009,3.799 3.084,6.874 6.885,6.883 l 0,0 C 26.799,29.874 29.874,26.799 29.883,23 l 0,0 C 29.874,19.199 26.799,16.124 23,16.116 l 0,0 C 19.199,16.124 16.124,19.199 16.115,23 l 0,0 z"
             ] []
      ]
