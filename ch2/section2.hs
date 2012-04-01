import Data.List (intersperse)

{-  Scheme lists using Cons, car, cdr. Probably I should just embrace
    Haskell and use the built in functions
        (:)  <==> cons
        head <==> car
        tail <==> cdr
    instead, but it feels important to keep something of the flavour of
    Scheme. -}

data Cons a = Nil | Cons a (Cons a) deriving (Eq)

instance Show a => Show (Cons a) where
    show x = "(" ++ str x ++ ")"
        where
            str  Nil         = ""
            str (Cons x Nil) = show x
            str (Cons x y)   = show x ++ " " ++ str y

car :: Cons a -> a
car Nil = error "Can't take the car of Nil"
car (Cons x _) = x

cdr :: Cons a -> Cons a
cdr Nil = error "Can't take the cdr of Nil"
cdr (Cons _ y) = y

cadr = car . cdr
cddr = cdr . cdr

list :: [a] -> Cons a
list []     = Nil
list (x:xs) = Cons x (list xs)

-- 2.17

{-  At the moment this only operates on lists of the same type. Hopefully I can
    figure out a way to make it operate on lists of objects of different types
    Maybe it's possible to wrap everything up in something like

        data SchemeObject = SO (forall a. Show a => a)

    Another option would be to define

        data SchemeObject = SchemeNum Double
                          | SchemeString String
                          | SchemeBool Bool
                          | ...

    but this is getting close to an "informally specified, bug-ridden
    implementation of half of Common Lisp." -}

lastPair :: Cons a -> Cons a
lastPair p@(Cons x Nil) = p
lastPair   (Cons x y)   = lastPair y

-- 2.18
reverseList :: Cons a -> Cons a
reverseList xs = iter xs Nil where
    iter  Nil result       = result
    iter (Cons x y) result = iter y (Cons x result)

-- 2.19
usCoins :: [Integer]
usCoins = [50,25,10,5,1]

ukCoins :: [Integer]
ukCoins = [100,50,20,10,5,2,1]

cc :: (Ord a, Num a, Num b) => a -> [a] -> b
cc amount coinValues
    | amount == 0                     = 1
    | amount < 0 || noMore coinValues = 0
    | otherwise =
        (cc amount (exceptFirstDenomination coinValues)) + 
        (cc (amount - (firstDenomination coinValues)) coinValues)
    where
        firstDenomination = head
        exceptFirstDenomination = tail
        noMore [] = True
        noMore xs = False

-- 2.20

{-  Haskell functions can't accept a variable number of arguments (it wouldn't
    play nice with the type system) but since this function expects integers,
    I figure it's okay for it to accept a list instead. -}

sameParity :: Integral a => [a] -> [a]
sameParity (x:xs) = x : fun xs where
    fun [] = []
    fun (y:ys) | parityMatch y = y : fun ys
               | otherwise     = fun ys
    parityMatch y = even (x - y)

-- 2.21
squareList :: Num a => [a] -> [a]
squareList []     = []
squareList (x:xs) = (x^2) : squareList xs

squareList' :: Num a => [a] -> [a]
squareList' xs = map (^2) xs

-- 2.22 n/a
-- Maybe I'll complete this exercise later.

-- 2.23
forEach :: Monad m => (a -> m b) -> [a] -> m ()
forEach f []     = return ()
forEach f (x:xs) = do f x
                      forEach f xs

-- 2.24 n/a
-- 2.25 n/a
-- 2.26 n/a

-- Tree data type, for holding lists nested to arbitrary depth.
data Tree a = Leaf a | Branch [Tree a] deriving (Eq)

instance Show a => Show (Tree a) where
    show (Leaf x)    = show x
    show (Branch xs) = "(" ++ interior ++ ")"
        where interior = concat $ intersperse " " (map show xs)

-- 2.27
reverseTree :: Tree a -> Tree a
reverseTree (Leaf x)    = Leaf x
reverseTree (Branch xs) = Branch (reverse xs)

deepReverseTree :: Tree a -> Tree a
deepReverseTree (Leaf x)    = Leaf x
deepReverseTree (Branch xs) = Branch (reverse $ map deepReverseTree xs)

-- 2.28
fringe :: Tree a -> [a]
fringe (Leaf a)    = [a]
fringe (Branch ts) = concat (map fringe ts)

-- 2.29
-- a.
data Rod a = Rod { len :: a, struct :: Mobile a } deriving (Eq,Show)

data Mobile a = Weight a
              | Mobile { left :: Rod a, right ::  Rod a }
              deriving (Eq,Show)

-- b.
totalWeight :: Num a => Mobile a -> a
totalWeight (Weight x)   = x
totalWeight (Mobile l r) = totalWeight (struct l) + totalWeight (struct r)

-- c.
balanced :: Num a => Mobile a -> Bool
balanced (Weight x)   = True
balanced (Mobile l r) = torque l == torque r
                        && balanced (struct l)
                        && balanced (struct r)
    where torque (Rod len str) = len * totalWeight str

-- 2.30
squareTree :: Num a => Tree a -> Tree a
squareTree (Leaf x)    = Leaf (x^2)
squareTree (Branch xs) = Branch (square xs)
    where square []     = []
          square (y:ys) = (squareTree y): square ys

squareTree :: Num a => Tree a -> Tree a
squareTree' (Leaf x)    = Leaf (x^2)
squareTree' (Branch xs) = Branch (map squareTree' xs)
