{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module StateT where

import           Control.Monad

newtype MyStateT s m a = MyStateT
  { runMyStateT :: s -> m (a, s)
  }

class MonadTrans t where
  lift :: Monad m => m a -> t m a

class (MonadState s m) where
  get :: m s
  put :: s -> m ()
  modify :: (s -> s) -> m ()

instance Monad m => Functor (MyStateT s m) where
  fmap = liftM

instance Monad m => Applicative (MyStateT s m) where
  pure a = MyStateT $ \s -> return (a, s)
  (<*>) = ap

instance Monad m => Monad (MyStateT s m) where
  return = pure
  (MyStateT a) >>= b =
    MyStateT $ \s -> do
      (a', s') <- a s
      runMyStateT (b a') s'

instance MonadTrans (MyStateT s) where
  lift m = MyStateT $ \s -> flip (,) s <$> m

instance Monad m => MonadState s (MyStateT s m) where
  get = MyStateT $ \s -> return (s, s)
  put s = MyStateT $ \_ -> return ((), s)
  modify f = get >>= put . f
