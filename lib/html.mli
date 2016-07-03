(*
 * Copyright (c) 2010 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** HTML library. *)

type t = Xml.t
(** A sequence of (X)HTML trees. *)

val doctype : string
(** @see <http://www.w3.org/TR/html5/syntax.html#the-doctype> The
    (X)HTML5 DOCTYPE. *)

val to_string : t -> string
(** [to_string html] is a valid (X)HTML5 polyglot string corresponding
    to the [html] structure. *)

val of_string : ?enc:Xml.encoding -> string -> t
(** [of_string ?enc html_str] is the tree representation of [html_str]
    as decoded by [enc]. For more information about the default
    encoding, see {!Xmlm.inenc}.

    Note that this function converts all
    {{:https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references}
    standard entities} into their corresponding UTF-8 symbol. *)

val output :
  ?nl:bool ->
  ?indent:int option ->
  ?ns_prefix:(string -> string option) -> Xmlm.dest -> t -> unit
(** Outputs valid (X)HTML5 polyglot text from a {!t}. Only non-void
    element handling is implemented so far. For more information
    about the parameters, see {!Xmlm.make_output}.

    @see <http://www.w3.org/TR/html-polyglot/> Polyglot Markup *)

val output_doc :
  ?nl:bool ->
  ?indent:int option ->
  ?ns_prefix:(string -> string option) -> Xmlm.dest -> t -> unit
(** Outputs a valid (X)HTML5 polyglot document from a {!t}. Only
    non-void element handling and HTML5 DOCTYPE is implemented so far.
    For more information about the parameters, see
    {!Xmlm.make_output}.

    @see <http://www.w3.org/TR/html-polyglot/> Polyglot Markup *)

(** {2 HTML library} *)


type rel =
  [ `alternate
  | `author
  | `bookmark
  | `help
  | `license
  | `next
  | `nofollow
  | `noreferrer
  | `prefetch
  | `prev
  | `search
  | `tag ]

type target = [ `blank | `parent | `self | `top | `Frame of string ]

val a:
  ?hreflang: string -> ?rel:rel ->  ?target:target ->  ?ty: string ->
  ?title: string -> ?cls: string ->  href:Uri.t -> t -> t
(** [a href html] generate a link from [html] to [href].

    @param title specifies extra information about the element that is
    usually as a tooltip text when the mouse moves over the element.
    Default: [None].

    @param target Specifies where to open the linked document.

    @param rel Specifies the relationship between the current document
    and the linked document.  Default: [None].

    @param hreflang the language of the linked document.  Default:
    [None].

    @param ty Specifies the media type of the linked document.  *)

val img : ?alt: string ->
          ?width: int ->
          ?height: int ->
          ?ismap: Uri.t ->
          ?title: string ->
          ?cls: string ->
          Uri.t -> t

val interleave : string array -> t list -> t list

val html_of_string : string -> t
(** @deprecated use {!string} *)

val string: string -> t

val html_of_int : int -> t
(** @deprecated use {!int} *)

val int: int -> t

val html_of_float : float -> t
(** @deprecated use {!float} *)

val float: float -> t

type table = t array array

val html_of_table : ?headings:bool -> table -> t

val nil: t
(** @deprecated use {!empty} *)

val empty: t

val concat : t list -> t
(** @deprecated use {!list} *)

val list: t list -> t
val some: t option -> t

(** [append par ch] appends ch to par *)
val append: t -> t -> t

val (++): t -> t -> t

module Create : sig
  module Tags : sig
    type html_list = [`Ol of t list | `Ul of t list]

    type color =
      | Rgba of char * char * char * char
      | Rgb of char * char * char

    type form_method =
      [ `GET | `POST ]

    type form_field =
        string
      * string option
      * [ `Text of string
      | `Radio of string list
      | `Submit
      | `Select of string list
      | `Textarea of string * int * int (* default value, rows, columns *)
      | `Password ]
      (** a `form_field` is a string representing the name of a field in an HTML
       * form along with the field's label and a descriptor of that field *)

    type table_flags =
        Headings_fst_col
      | Headings_fst_row
      | Sideways
      | Heading_color of color
      | Bg_color of color

    type 'a table =
      [ `Tr of 'a table list | `Td of 'a * int * int | `Th of 'a * int * int ]
  end

  type t = Xml.t

  val stylesheet : string -> t
  (** [stylesheet style] converts a CSS string to a valid HTML stylesheet *)

  val table :
    ?flags:(Tags.table_flags list) ->
    row:('a -> t list) ->
    'a list ->
    t
  (** [table ~flags:f ~row:r tbl] produces an HTML table formatted according to
      [f] where each row is generated by passing a member of [tbl] to [r].

      @param flags a list of type [Cow.Html.Flags.table_flags] specifying how
      the generated table is to be structured.

      @param row a function to transform a single row of the input table (a
      single element of the list, that is) into a list of elements, each of
      which will occupy a cell in a row of the table.

      [tbl:] a list of (probably) tuples representing a table.

      See the following example:
{[
let row = (fun (name,email) -> [ <:html<$str:name$>>; <:html<$str:email$>>]) in
let data =
  \[ "Name","Email Address";
    "John Christopher McAlpine","christophermcalpine\@gmail.com";
    "Somebody McElthein","johnqpublic\@something.something";
    "John Doe","johndoe\@johndoe.com"; \] in
let table = Cow.Html.Create ~flags:[Headings_fst_row] ~row data
]}
      which produces the HTML table
{%html:
<!DOCTYPE html>
<table>
  <tr>
    <th>Name</th>                       <th>Email Address</th>
  </tr>
  <tr>
    <td>John Christopher McAlpine</td>  <td>christophermcalpine\@gmail.com</td>
  </tr>
  <tr>
    <td>Somebody McElthein</td>         <td>johnqpublic\@something.something</td>
  </tr>
  <tr>
    <td>John Doe</td>                   <td>johndoe\@johndoe.com</td>
  </tr>
</table>
%}
*)

  val form :
    action:string ->
    meth:Tags.form_method ->
    Tags.form_field list -> t
  (** [form ~action:url ~meth:method fields] produces an HTML form with the
   * fields described by [fields], with the action pointed to by [url], using
   * the method indicated my [method].
   *
   * notes: this is a work in progress, in particular the [form_field list] is
   * a bit of a mess. I plan on adding additional functionality in the future,
   * but only through optional parameters, so the current signature contains
   * everything that is absolutely necessary to make a complete and functional
   * HTML form. The [action] parameter could also maybe be converted into a
   * dedicated [uri] type, although I tend not to like this sort of thing. *)
end

(** {1 HTML nodes} *)

type node = ?cls:string -> ?id:string -> ?attrs:(string * string) list -> t -> t
(** The type for nodes. *)

val div: node
(** [div ~cls t] is [<div class="cls">t</div>]. *)

val span: node
(** [div ~cls: t] is [<div class="cls">t</div>]. *)

val input: node
val link: ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?title:string -> ?href:Uri.t -> ?rel:string -> ?media:string -> t -> t
val meta: ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?name:string -> ?content:string -> ?charset:string -> t -> t
val br: node
val hr: node
val source: node
val wbr: node
val param: node
val embed: node
val col: node
val track: node
val keygen: node
val anchor: string -> t
val base: ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
           ?href:Uri.t -> ?target:string -> t -> t
val style: ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
           ?media:string -> ?typ:string -> t -> t

val h1: node
val h2: node
val h3: node
val h4: node
val h5: node
val h6: node

val small: node

val li: node
val dt: node
val dd: node

val ul: ?add_li:bool ->
  ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?licls:string -> t list -> t

val ol: ?add_li:bool ->
  ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?licls:string -> t list -> t

val dl: ?add_dtdd:bool ->
  ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?dtcls:string -> ?ddcls:string -> (t * t) list -> t

val tag: string -> node

val i: node
val p: node
val tt: node
val blockquote : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?cite:Uri.t -> t -> t
val pre : node
val figure : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?figcaption:t -> t -> t
val main : node

val em : node
val strong : node
val s : node
val cite : node
val q : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?cite:Uri.t -> t -> t
val dfn : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?title:string -> t -> t
val abbr : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?title:string -> t -> t
val data : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  value:string -> t -> t
val time : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?datetime:string -> t -> t
val code : node
val var : node
val samp : node
val kbd : node
val sub : node
val sup : node
val b : node
val u : node
val mark : node
val bdi : node
val bdo : node

val ruby : node
val rb : node
val rt : node
val rtc : node
val rp : node

val aside: node

val ins : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?cite:Uri.t -> ?datetime:string -> t -> t
val del : ?cls:string -> ?id:string -> ?attrs:(string * string) list ->
  ?cite:Uri.t -> ?datetime:string -> t -> t

val html: node
val footer: node
val title: node
val head: node
val header: node
val body: node
val nav: node
val section: node
val article: node
val address: node

val script: ?src:string -> ?typ:string -> ?charset:string -> t -> t
