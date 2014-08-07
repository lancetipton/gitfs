from pygit2 import (Repository as _Repository, clone_repository,
                    GIT_CHECKOUT_SAFE_CREATE, Signature, GIT_BRANCH_REMOTE,
                    GIT_CHECKOUT_FORCE)


class Repository(_Repository):
    def push(self, upstream, branch):
        """ Push changes from a branch to a remote

        Examples::

                repo.push("origin", "master")
        """

        remote = self.get_remote(upstream)
        remote.push("refs/heads/%s" % (branch))

    def pull(self, upstream, branch_name):
        """ Fetch from a remote and merge the result in local HEAD.

        Examples::

                repo.pull("origin", "master")
        """

        # fetch from remote
        remote = self.get_remote(upstream)
        remote.fetch()

        # merge with new changes
        branch = self.lookup_branch("%s/%s" % (upstream, branch_name),
                                    GIT_BRANCH_REMOTE)
        self.merge(branch.target)
        self.create_reference("refs/heads/%s" % branch_name,
                              branch.target, force=True)

        # TODO: get commiter from env
        # create commit
        commit = self.commit("Merging", "Vlad", "vladtemian@gmail.com")

        # update head to newly created commit
        self.create_reference("refs/heads/%s" % branch_name,
                              commit, force=True)
        self.checkout_head(GIT_CHECKOUT_FORCE)

        # cleanup the merging state
        self.clean_state_files()

    def commit(self, message, author, commiter, ref="HEAD"):
        """ Wrapper for create_commit. It creates a commit from a given ref
        (default is HEAD)
        """

        # sign the author
        author = Signature(author[0], author[1])
        commiter = Signature(commiter[0], commiter[1])

        # write index localy
        tree = self.index.write_tree()
        self.index.write()

        # get parent
        parent = self.revparse_single(ref)
        return self.create_commit(ref, author, commiter, message,
                                  tree, [parent.id])

    @classmethod
    def clone(cls, remote_url, path, branch=None):
        """Clone a repo in a give path and update the working directory with
        a checkout to head (GIT_CHECKOUT_SAFE_CREATE)

        :param str remote_url: URL of the repository to clone

        :param str path: Local path to clone into

        :param str branch: Branch to checkout after the
        clone. The default is to use the remote's default branch.

        """

        repo = clone_repository(remote_url, path, checkout_branch=branch)
        repo.checkout_head(GIT_CHECKOUT_SAFE_CREATE)
        return cls(path)

    def get_remote(self, name):
        """ Retrieve a remote by name. Raise a ValueError if the remote was not
        added to repo

        Examples::

                repo.get_remote("fork")
        """
        remote = [remote for remote in self.remotes
                  if remote.name == name]
        if not remote:
            raise ValueError("Missing remote")

        return remote[0]
