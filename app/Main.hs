{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Data.Bifunctor
import qualified Data.ByteString.Char8 as BS
import Data.ByteString.UTF8
import Data.List (intersperse)
import Data.Maybe
import qualified Data.Text as T
import qualified Data.Text.Encoding as E
import System.Directory
import System.Environment
import System.IO
import System.Posix.ByteString.FilePath

import System.INotify

import qualified Data.ByteString.Builder as BSB
import qualified RawFilePath.Directory as D
import qualified Turtle as Tu

main :: IO ()
main = do
    args <- map fromString <$> getArgs
    let pwd :: RawFilePath = "./"
    home :: RawFilePath <- fromMaybe "" <$> D.getHomeDirectory
    let (dirs, cmd) = first (BS.split ',') $ if null args then (pwd, ["cabal", "test"]) else (head args, tail args)
    inotify <- initINotify
    print inotify
    wds <-
        mapM
            ( \dir ->
                addWatch
                    inotify
                    [Modify]
                    dir
                    ( \x -> do
                        print x
                        Tu.shell (T.intercalate " " . map E.decodeUtf8 $ cmd) Tu.empty
                        BS.putStrLn "done"
                    )
            )
            dirs
    BSB.hPutBuilder stdout (mconcat $ intersperse (BSB.char7 ' ') (["Listens to your"] <> (map BSB.byteString dirs) <> ["directory and will do ["] <> (map BSB.byteString cmd) <> ["]. Hit enter to terminate."]))
    BS.getLine
    mapM_ removeWatch wds
