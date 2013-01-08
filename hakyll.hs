{-# LANGUAGE OverloadedStrings #-}

import Hakyll
import Control.Arrow ((>>>), (***), arr)
import Data.Monoid (mempty, mconcat)

main :: IO ()
main = hakyll $ do
        match "css/*" $ do
                route   idRoute
                compile compressCssCompiler

        match (list [ "publications.mkd", "research-agenda.mkd"
                    , "past-research.mkd", "index.markdown"
                    ]) $ do
                route   $ setExtension "html"
                compile $ pageCompiler
                        >>> applyTemplateCompiler "templates/default.html"
                        >>> relativizeUrlsCompiler

        match "notes/*.mkd" $ do
                route   $ setExtension "html"
                compile $ pageCompiler
                        >>> applyTemplateCompiler "templates/default.html"
                        >>> relativizeUrlsCompiler
     
        match "media/**" $ do
                route   idRoute
                compile copyFileCompiler

        match "index.html" $ route idRoute
        create "index.html" $ constA mempty
                >>> arr (setField "title" "Home")
                >>> applyTemplateCompiler "templates/index.html"
                >>> applyTemplateCompiler "templates/default.html"
                >>> relativizeUrlsCompiler

        match "notes.html" $ route idRoute
        create "notes.html" $ constA mempty
                >>> arr (setField "title" "Notes")
                >>> requireAllA "notes/*.mkd" addPostList
                >>> applyTemplateCompiler "templates/notes.html"
                >>> applyTemplateCompiler "templates/default.html"
                >>> relativizeUrlsCompiler

        match "templates/*" $ compile templateCompiler


addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = setFieldA "notes" $
    arr (reverse . chronological)
        >>> require "templates/noteitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody

