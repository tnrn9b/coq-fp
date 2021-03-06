Require Import FP.CoreClasses.
Require Import FP.CoreData.
Require Import FP.DerivingEverything.
Require Import FP.Classes.

Import CoreClassesNotation.
Import CoreDataNotation.

Inductive identity A := Identity { run_identity : A }.
Arguments Identity {A} _.
Arguments run_identity {A} _.

Section identity_Bijection.
  Context {A:Type}.

  Global Instance IR_un_identity_eq
    : InjectionRespect (identity A) A run_identity eq eq.
  Proof.
    constructor ; [congruence|].
    unfold Proper,"<==" ; intros ; destruct x,y ; simpl in * ; congruence.
  Qed.

  Global Instance II_Identity_eq
    : InjectionInverse A (identity A) Identity run_identity eq.
  Proof.
    constructor ; auto.
  Qed.
End identity_Bijection.

Module identity_DE_Arg <: DE_Functor_Arg.
  Definition T := identity.
  Definition U := id:Type->Type.
  Definition to : forall {A}, T A -> U A := @run_identity.
  Definition from : forall {A}, U A -> T A := @Identity.
  Definition IR_to {A} : InjectionRespect (T A) (U A) to eq eq := _.
  Definition II_from {A} : InjectionInverse (U A) (T A) from to eq := _.
  Definition _DE_FunctorI : DE_FunctorI' U.
  Proof. econstructor ; econstructor ; eauto with typeclass_instances. Defined.
End identity_DE_Arg.
Module identity_DE := DE_Functor identity_DE_Arg.
Import identity_DE.

Section Proper.
  Context {A} `{! Eqv A }.
  Global Instance Identity_Proper : Proper eqv (@Identity A).
  Proof.
    unfold Proper.
    logical_eqv_intro.
    unfold eqv ; auto.
  Qed.
  Global Instance run_identity_Proper : Proper eqv (@run_identity A).
  Proof.
    unfold Proper.
    logical_eqv_intro.
    destruct x,y ; auto.
  Qed.
End Proper.

Section Monad.
  Definition identity_mret {A} : A -> identity A := Identity.
  Arguments identity_mret {A} _ /.
  Definition identity_mbind {A B} (aM:identity A) (k:A -> identity B) : identity B :=
    k $ run_identity aM.
  Arguments identity_mbind {A B} _ _ /.
  Global Instance identity_Monad : Monad identity :=
    { mret := @identity_mret
    ; mbind := @identity_mbind
    }.

  Global Instance identity_MonadWF : MonadWF identity.
  Proof.
    constructor ; intros ; unfold mret,mbind ; simpl ; logical_eqv.
    unfold Proper ; logical_eqv_intro ; simpl ; logical_eqv.
  Qed.
End Monad.

Section Comonad.
  Definition identity_coret {A} : identity A -> A := run_identity.
  Arguments identity_coret {A} _ /.
  Definition identity_cobind {A B} (aM:identity A) (k:identity A -> B) : identity B :=
    Identity $ k aM.
  Global Instance identity_Comonad : Comonad identity :=
    { coret := @identity_coret
    ; cobind := @identity_cobind
    }.
End Comonad.